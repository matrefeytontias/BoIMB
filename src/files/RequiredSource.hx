package files;

import haxe.io.Path;
import sys.io.File;
import sys.io.FileInput;

class RequiredSource extends SourceFile
{
    public var relativePathToSource(default, null):String;
	
	public function setSource(source:SourceFile)
	{
		var d = Path.directory(source.path);
		relativePathToSource = source.path.split(d)[1];
		trace(relativePathToSource);
	}
}