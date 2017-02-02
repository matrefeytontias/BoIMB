package files;

import haxe.io.Eof;
import sys.io.*;

class SourceFile
{
	public var path:String;
	private var lines:Array<String>;
	
	public function new(p:String)
	{
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