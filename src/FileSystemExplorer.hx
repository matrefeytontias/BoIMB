import sys.FileSystem;

class FileSystemExplorer
{
	static public function explore(dir:String, process:String -> Bool)
	{
		var content:Array<String> = FileSystem.readDirectory(dir);
		for(e in content)
		{
			var filename = dir + "/" + e;
			
			if(process(filename) && FileSystem.isDirectory(filename))
				explore(filename + "/", process);
		}
	}
}