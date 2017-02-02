package files;

import haxe.io.Path;

class MainSource extends SourceFile
{
	public var modName:String;
	
	public function new(p:String, dir:String)
	{
		super(p, dir);
		
		for(l in lines)
		{
			var m:EReg = ~/^ *local *([a-zA-Z](_|\.|[a-zA-Z0-9])*) *= *RegisterMod *\(.*\)/i;
			if(m.match(l))
			{
				modName = m.matched(1);
				lines.remove(l); // get rid of the RegisterMod line
				return;
			}
		}
		throw '[$dirname] main.lua must contain RegisterMod';
	}
}
