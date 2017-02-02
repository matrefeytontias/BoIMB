class Main
{
	static public var modName:String;
	static public var outName:String;
	static public var outDir:String;
	
	static public function main()
	{
		var args = Sys.args();
		
		trace("");
		trace("######################################");
		trace("#  The Binding of Isaac Afterbith +  #");
		trace("# Modpack Builder by Matrefeytontias #");
		trace("######################################\n");
		
		if(args.length != 3)
		{
			trace("\nUsage : BoIMB <mod name> <input dir> <output dir>");
		}
		else
		{
			modName = args[0];
			outDir = Sys.getCwd() + "/" + args[2];
			Sys.setCwd(Sys.getCwd() + "/" + args[1]);
			outName = args[2];
			try
			{
				ModpackBuilder.build();
			}
			catch (e:String)
			{
				trace("[ERROR]   : " + e);
			}
		}
	}
	
	static public function warning(s:String)
	{
		trace("[WARNING] : " + s);
	}
}
