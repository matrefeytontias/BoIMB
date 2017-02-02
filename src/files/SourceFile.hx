package files;

import sys.io.File;
import sys.io.FileInput;

class SourceFile
{
    public var path:String;
    public var out:FileInput;
    
    public function new(p:String)
    {
        path = p;
        out = File.read(p, false);
    }
}