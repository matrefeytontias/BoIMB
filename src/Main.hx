class Main
{
	static private var LOGLEVEL_ALLOWLOG(default, never) = 1;
	static private var LOGLEVEL_ALLOWINFO(default, never) = 2;
	static private var LOGLEVEL_ALLOWWARNING(default, never) = 4;
	static private var LOGLEVEL_ALLOWERROR(default, never) = 8;
	
	static private var logLevel = LOGLEVEL_ALLOWERROR | LOGLEVEL_ALLOWWARNING | LOGLEVEL_ALLOWINFO;
	
	static public var modName:String;
	static public var outName:String;
	static public var outDir:String;
	
	static public function main()
	{
		var args = Sys.args();
		
		Sys.println("");
		Sys.println("######################################");
		Sys.println("#  The Binding of Isaac Afterbith +  #");
		Sys.println("# Modpack Builder by Matrefeytontias #");
		Sys.println("######################################\n");
		
		if(args.length != 3)
		{
			Sys.println("\nUsage : BoIMB <mod name> <input dir> <output dir>");
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
				if(logLevel & LOGLEVEL_ALLOWERROR != 0)
					Sys.println("[\033[31mERROR\033[0;37m] : " + e);
			}
		}
	}
	
	static public function warning(s:String)
	{
		if(logLevel & LOGLEVEL_ALLOWWARNING != 0)
			Sys.println("[\033[33mWARN\033[0;37m]  : " + s);
	}
	
	static public function info(s:String)
	{
		if(logLevel & LOGLEVEL_ALLOWINFO != 0)
			Sys.println("[\033[32mINFO\033[0;37m]  : " + s);
	}
	
	static public function log(s:String)
	{
		if(logLevel & LOGLEVEL_ALLOWLOG != 0)
			Sys.println("[\033[1;34mLOG\033[0;37m]   : " + s);
	}
}
