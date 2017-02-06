package compiler;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

import files.*;

using Mod.RelativePath;

class RelativePath
{
	static public function relativeTo(s1:String, s2:String) : String
	{
		return s1.split(s2 + "/")[1];
	}
}

typedef ResourcePath = {modName:String, path:String};

class Mod
{
	public var name:String;
	public var dirname:String;
	
	private var path:String;
	private var contentPath:String;
	private var resourcesPath:String;
	
	private var mainSource:MainSource;
	private var requiredSources:Array<RequiredSource>;
	
	private var compiledResult:String;
	private var contentFilesNames:Array<String>;
	private var resourcesNames:Array<String>;
	private var targetArray:Array<String>; // grab files via the getFiles callback
	
	// Assumes path is a valid mod
	public function new(_path:String)
	{
		path = _path;
		contentPath = path + "/content";
		resourcesPath = path + "/resources";
		contentFilesNames = new Array<String>();
		resourcesNames = new Array<String>();
		requiredSources = new Array<RequiredSource>();
		var s = path.split('/');
		dirname = s[s.length - 1];
		
		// Find all .lua files
		FileSystemExplorer.explore(path, findLuaFiles);
		// Build relative paths of RequiredSources
		for(r in requiredSources)
			r.setSource(mainSource);
	}
	
	// Doesn't matter if we return true for a file
	private function findLuaFiles(p:String) : Bool
	{
		if(!FileSystem.isDirectory(p))
		{
			var pathObject = new Path(p);
			if(pathObject.ext.toLowerCase() == "lua")
			{
				if(pathObject.file.toLowerCase() == "main")
				{
					if(mainSource != null)
						throw '[$dirname] cannot have more than one main.lua per mod.';
					mainSource = new MainSource(p, dirname);
					name = mainSource.modName;
				}
				else
					requiredSources.push(new RequiredSource(p, dirname));
			}
		}
		return true;
	}
	
	public function compile()
	{
		// Compile Lua source files (they need a shitton of stuff to be done to them)
		Main.info("Compiling mod " + dirname + " with name " + name  + " ...");
		compiledResult = Parser.compile(mainSource, requiredSources);
		
		// Compile content files (they need XML merging)
		Main.info("Gathering content files ...");
		if(FileSystem.exists(contentPath))
		{
			var content = FileSystem.readDirectory(contentPath);
			if(content.length > 0)
			{
				contentFilesNames = new Array<String>();
				targetArray = contentFilesNames;
				FileSystemExplorer.explore(contentPath, getFiles);
			}
		}
		if(contentFilesNames.length == 0)
			Main.info("No content file found.");
		
		// Compile resource files (they take no additional processing)
		Main.info("Gathering resource files ...");
		if(FileSystem.exists(resourcesPath))
		{
			var resources = FileSystem.readDirectory(resourcesPath);
			if(resources.length > 0)
			{
				resourcesNames = new Array<String>();
				targetArray = resourcesNames;
				FileSystemExplorer.explore(resourcesPath, getFiles);
			}
		}
		if(resourcesNames.length == 0)
			Main.info("No resource file found.");
		
		Main.info("Done !");
		Main.info("");
	}
	
	public function getResourceFilenames() : Array<ResourcePath>
	{
		var array = new Array<ResourcePath>();
		for(r in resourcesNames)
			array.push({modName:dirname, path:r});
		return array;
	}
	
	private function getFiles(p:String) : Bool
	{
		// Ignore files in the same directory as main.lua
		// Don't ignore Windows-created thumbnails but don't display them
		if(!FileSystem.isDirectory(p) && p.substr(0, p.lastIndexOf("/")) != path)
		{
			var np = p.relativeTo(path);
			if(p.substr(p.lastIndexOf("/") + 1) != "Thumbs.db")
				Main.info("  " + np);
			targetArray.push(np);
		}
		return true;
	}
	
	public function writeCompiledResult(dir:String, f:FileOutput)
	{
		// Write the compiled Lua code
		var s = "\n-- #";
		var n = dirname.length + 4;
		for(i in 0 ... n - 1)
			s += "#";
		f.writeString(s + "\n");
		f.writeString("-- # " + dirname + " #");
		f.writeString(s + "\n\n");
		f.writeString(compiledResult);
		
		// Merge the XML files with the ones already existing
		if(contentFilesNames.length > 0)
			FileSystem.createDirectory(dir + "/content");
		for(f in contentFilesNames)
		{
			if(FileSystem.exists(dir + "/" + f))
				Main.warning("XML merging is not yet supported ; overwriting " + f);
			File.copy(path + "/" + f, dir + "/" + f);
		}
		
		if(resourcesNames.length > 0)
			FileSystem.createDirectory(dir + "/resources");
		for(f in resourcesNames)
		{
			if(FileSystem.exists(dir + "/" + f))
				Main.warning("Collision in file " + f + " ; resources with conflicting names.");
			else
				makeFileTree(dir, f);
			File.copy(path + "/" + f, dir + "/" + f);
		}
	}
	
	// Creates all necessary directories to create a file
	private function makeFileTree(root:String, target:String)
	{
		var dirs = Path.normalize(target).split('/');
		var r = "";
		for(k in 0 ... dirs.length - 1) // omit file name
		{
			r += dirs[k] + "/" ;
			var n = root + "/" + r;
			if(!FileSystem.exists(n))
				FileSystem.createDirectory(n);
		}
	}
	
	public function report()
	{
		Main.info(dirname + " contains " + (requiredSources.length + 1) + " Lua file(s) :");
		Main.info("  main.lua");
		for(r in requiredSources)
			Main.info("  " + r.relativePathToSource);
	}
}