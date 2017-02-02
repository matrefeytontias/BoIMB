package compiler;

class Variable
{
	public var global:Bool;
	public var oldName:String;
	public var newName:String;
	public var nameAllows:String;
	
	public function new(old:String, newN:String, g:Bool, n:String = "")
	{
		global = g;
		oldName = old;
		newName = newN;
		nameAllows = n;
	}
}
