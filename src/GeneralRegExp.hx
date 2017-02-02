class GeneralRegExp
{
	static public var modName:EReg = ~/^ *local *([a-zA-Z](_|[a-zA-Z0-9])*) *= *RegisterMod *\(.*\)/i;
	static public var assignation:EReg = ~/^ *(local|function)? *([a-zA-Z](_|[a-zA-Z0-9])*) *=.*/i;
	static public var require:EReg = ~/require\((.*)\)/i;
	static public var startsBlock:EReg = ~/$ *((if|for|while) +|do *$)/i;
}