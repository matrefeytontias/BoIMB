package files;

class MainSource extends SourceFile
{
	public var modName:String;
	
	public function new(p:String)
	{
		super(p);
		
		for(l in lines)
		{
			if(GeneralRegExp.modName.match(l))
			{
				modName = GeneralRegExp.modName.matched(1);
				lines.remove(l); // get rid of the RegisterMod line
				return;
			}
		}
		throw "main.lua must contain RegisterMod";
	}
}
