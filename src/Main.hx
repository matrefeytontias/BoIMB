class Main
{
    static public var outName:String;
    
    static public function main()
    {
        outName = Sys.args()[0];
        try
		{
			ModpackBuilder.build();
		}
		catch (e:String)
		{
			trace("[ERROR]   : " + e);
		}
    }
	
	static public function warning(s:String)
	{
		trace("[WARNING] : " + s);
	}
}
