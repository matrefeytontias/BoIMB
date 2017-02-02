package files;

import haxe.io.Eof;
import haxe.io.Path;
import sys.io.*;

class SourceFile
{
	public var path:String;
	private var lines:Array<String>;
	
	private function new(p:String)
	{
		p = Path.normalize(p);
		path = p;
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