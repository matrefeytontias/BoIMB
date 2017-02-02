package files;

import haxe.io.Eof;
import haxe.io.Path;
import sys.io.*;

class SourceFile
{
	public var path:String;
	public var name:String;
	public var dirname:String;
	public var lines:Array<String>;
	
	private function new(p:String, dir:String)
	{
		p = Path.normalize(p);
		path = p;
		name = Path.withoutDirectory(p);
		dirname = dir;
		var out = File.read(p, false);
		lines = new Array<String>();
		
		while(true)
		{
			try
			{
				lines.push(out.readLine());
			}
			catch(e:Eof)
			{
				break;
			}
		}
	}
}