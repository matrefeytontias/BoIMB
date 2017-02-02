package files;

import haxe.io.Path;
import sys.io.File;
import sys.io.FileInput;

class RequiredSource extends SourceFile
{
	public var relativePathToSource(default, null):String;
	
	public function new(p:String, dir:String)
	{
		super(p, dir);
	}
	
	public function setSource(source:SourceFile)
	{
		dirname = Path.directory(source.path) + '/';
		relativePathToSource = path.split(dirname)[1];
	}
}