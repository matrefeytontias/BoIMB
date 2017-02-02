package files;

class MainSource extends SourceFile
{
	public function getModName() : String
	{
		for(l in lines)
		{
			if(GeneralRegExp.modName.match(l))
				return GeneralRegExp.modName.matched(1);
		}
		throw "main.lua must contain RegisterMod";
	}
}
