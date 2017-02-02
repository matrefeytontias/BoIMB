package files;

class MainSource extends SourceFile
{
	public function getModName() : String
	{
		var l:String = out.readLine();
		var e = ~/^ *local *([a-zA-Z](_|[a-zA-Z0-9])*) *= *RegisterMod *\(.*\)/i;
		while(l != null)
		{
			if(e.match(l))
				return e.matched(1);
			l = out.readLine();
		}
		throw "main.lua must contain RegisterMod";
	}
}
