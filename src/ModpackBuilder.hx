import sys.io.File;
import sys.FileSystem;

import compiler.Mod;

class ModpackBuilder
{
	static private var mods:Array<Mod> = new Array<Mod>();
	
	static public function build()
	{
		// Retrieve all mods
		// Mods are directories with a main.lua file
		trace("Searching for mods ...\n");
		FileSystemExplorer.explore(Sys.getCwd(), process);
		
		for(m in mods)
			m.report();
		
		// Let all the errors happen before writing anything
		for(m in mods)
			m.compile();
		
		FileSystem.createDirectory(Main.outDir);
		var f = File.write(Main.outDir + "/main.lua", false);
		f.writeString("local " + Main.outName + ' = RegisterMod("' + Main.modName + '", 1)\n\n');
		for(m in mods)
			m.writeCompiledResult(f);
		f.close();
	}
	
	static private function process(path:String) : Bool
	{
		var r = FileSystem.isDirectory(path) && FileSystem.readDirectory(path).indexOf("main.lua") > -1;
		// Don't select the mod if it has the same name as the output mod
		if(r)
			mods.push(new Mod(path));
		return !r;
	}
}