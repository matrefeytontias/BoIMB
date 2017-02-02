import sys.FileSystem;

import compiler.Mod;

class ModpackBuilder
{
	static private var mods:Array<Mod> = new Array<Mod>();
	
	static public function build()
	{
		// Retrieve all mods
		// Mods are directories with a main.lua file
		FileSystemExplorer.explore(Sys.getCwd(), process);
		trace("Found " + mods.length + " mods :");
		for(m in mods)
		{
			trace("  " + m.name + ", " + m.dirname);
		}
	}
	
	static private function process(path:String) : Bool
	{
		var r = FileSystem.isDirectory(path) && FileSystem.readDirectory(path).indexOf("main.lua") > -1;
		if(r)
			mods.push(new Mod(path));
		return !r;
	}
}