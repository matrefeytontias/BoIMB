import haxe.io.Path;

import sys.FileSystem;

class FileSystemExplorer
{
	static public function explore(dir:String, process:String -> Bool, ?postDir:String -> Void)
	{
		if(!FileSystem.isDirectory(dir))
			return;
		var content:Array<String> = FileSystem.readDirectory(dir);
		for(e in content)
		{
			var filename = Path.addTrailingSlash(dir) + e;
			
			if(process(filename) && FileSystem.isDirectory(filename))
			{
				explore(filename + "/", process);
				if(postDir != null)
					postDir(dir);
			}
		}
	}
	
	static public function deleteDirectory(dir:String)
	{
		explore(dir, function (f:String) : Bool
			{
				if(!FileSystem.isDirectory(f))
					FileSystem.deleteFile(f);
					return true; }, function (d:String) { FileSystem.deleteDirectory(d); });
	}
}