package compiler;

import files.MainSource;
import files.RequiredSource;

using StringTools;

using Parser.MoreStrings;

class MoreStrings
{
	static public function isTokenChar(s1:String, allow:String = "") : Bool
	{
		return (s1 >= 'A' && s1 <= 'Z') || (s1 >= 'a' && s1 <= 'z') || (s1 >= '0' && s1 <= '9') || (s1 == '_') || (allow.indexOf(s1) > -1);
	}
	
	static public function skipSpaces(s:String, i:Int) : Int
	{
		while(s.charAt(i) == ' ' || s.charAt(i) == '\t')
			i++;
		return i;
	}
	
	static public function indexOfToken(s1:String, s2:String, allowRight:String = "") : Int // returns the position of the byte AFTER the occurence or -1 if not found
	{
		var c1:Int = 0, c2:Int = 0;
		while(c2 < s2.length && c1 <= s1.length - (s2.length - c2))
		{
			// trace(s1.charAt(c1), s2.charAt(c2));
			if(s1.charAt(c1) == s2.charAt(c2))
			{
				if(c2 == 0 && (c1 == 0 || !s1.charAt(c1 - 1).isTokenChar()))
					c2++;
				else if(c2 > 0)
					c2++;
			}
			else
				c2 = 0;
			c1++;
		}
		return c2 == s2.length && (c1 + 1 >= s1.length || !s1.charAt(c1).isTokenChar(allowRight)) ? c1 : -1;
	}
	
	static public function hasOneOfTokens(s:String, a:Array<String>) : Bool
	{
		for(t in a)
		{
			if(s.indexOfToken(t) > -1)
				return true;
		}
		return false;
	}
	
	static public function getNextToken(s:String, c:Int, allowRight:String = "") : {token:String, nextPos:Int} // c is the starting index
	{
		var r = "";
		while(!s.charAt(c).isTokenChar() && c < s.length)
			c++;
		
		if(c >= s.length)
			return {token:null, nextPos:s.length};
			
		var char = s.charAt(c);
		while(c < s.length && char.isTokenChar(allowRight))
		{
			r += char;
			c++;
			char = s.charAt(c);
		}
		return {token:r, nextPos:c};
	}
}

class Parser
{
	static private var modName:String;
	static private var lines:Array<String>;
	static private var context:Map<String, Variable>;
	
	static public function compile(main:MainSource, r:Array<RequiredSource>) : String
	{
		modName = main.modName;
		lines = main.lines;
		var sa = runCompile();
		// TODO : process required sources
		var s = "";
		for(l in sa)
			s += l + "\n";
		return s;
	}
	
	static private function runCompile() : Array<String>
	{
		// First, build the context, ie find all variable names that need replacement
		buildContext();
		// Then, loop through the context and replace all global tokens
		for(k in context.keys())
		{
			for(l in 0 ... lines.length)
			{
				var v:Variable = context.get(k);
				if(v.global)
				{
					var o:Int;
					while((o = lines[l].indexOfToken(k, v.nameAllows)) > -1)
					{
						lines[l] = lines[l].substr(0, o - k.length) + v.newName + lines[l].substr(o);
					}
				}
			}
		}
		return lines;
	}
	
	// Analyzes the Lua lines to find all global variables and functions
	// Those are the one that will need replacement
	static private function buildContext()
	{
		var blockCounter:Int = 0;
		
		context = new Map<String, Variable>();
		
		// Add a variable to replace the mod itself
		context.set(modName, new Variable(modName, Main.outName, true));
		
		for(l in 0 ... lines.length)
		{
			var o = lines[l].indexOfToken("function");
			if(o > -1) // detects a function and local function
			{
				var varname = lines[l].getNextToken(o, ".:").token;
				var s = varname.split(":");
				var v = new Variable(varname,
									s[0] == modName ? Main.outName + ":" + s[0] + "_" + s[1] : modName + "_" + varname,
									lines[l].indexOfToken("local") > -1 ? blockCounter == 0 : true, ".:");
				context.set(varname, v);
				s = v.oldName.split(":");
				var ns = v.newName.split(":");
				context.set(s[0] + "." + s[1], new Variable(s[0] + "." + s[1], ns[0] + "." + ns[1], v.global, ".:"));
				blockCounter++;
			}
			else if((o = lines[l].indexOfToken("local")) > -1) // detects a local variable
			{
				var r = lines[l].getNextToken(o);
				var varname = r.token;
				if(!context.exists(varname))
					context.set(varname, new Variable(varname, modName + "_" + varname, blockCounter == 0));
			}
			else if(lines[l].hasOneOfTokens(["if", "elseif", "else", "for", "while", "do"])) // detects the start of a block
				blockCounter++;
			else if(lines[l].indexOfToken("end") > -1) // detects the end of a blck
				blockCounter--;
			else // detects generic assignation
			{
				var r = lines[l].getNextToken(0);
				if(r.token != null)
				{
					var varname = r.token;
					// See if we find a = sign right away
					if(lines[l].charAt(lines[l].skipSpaces(r.nextPos)) == "=" && !context.exists(varname))
						context.set(varname, new Variable(varname, modName + "_" + varname, true));
				}
			}
		}
	}
}
