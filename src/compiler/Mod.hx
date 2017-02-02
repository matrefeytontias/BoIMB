package compiler;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;

import files.*;

class Mod
{
	public var name:String;
	public var dirname:String;
	private var path:String;
	private var mainSource:MainSource;
	private var requiredSources:Array<RequiredSource>;
	
	// Assumes path is a valid mod
	public function new(_path:String)
	{
		path = _path;
		requiredSources = new Array<RequiredSource>();
		var s = path.split('/');
		dirname = s[s.length - 1];
		
		// Find all .lua files
		FileSystemExplorer.explore(path, findLuaFiles);
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
						throw "cannot have more than one main.lua per mod.";
					mainSource = new MainSource(p);
					name = mainSource.modName;
				}
				else
					requiredSources.push(new RequiredSource(p));
			}
		}
		return true;
	}
}