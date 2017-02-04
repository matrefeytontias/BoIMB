package compiler;

import files.MainSource;
import files.RequiredSource;

using StringTools;

using Parser.MoreStrings;

class MoreStrings
{
	static public function countChar(s:String, c:String) : Int
	{
		var count = 0;
		for(k in 0 ... s.length)
			if(s.charAt(k) == c)
				count++;
		return count;
	}
	static public function hasTokenInStringConstant(line:String, token:String, pos:Int) : Bool
	{
		// The token is in a string constant if the number of quotes is odd on both sides
		return line.substr(0, pos).countChar('"') * line.substr(pos + token.length).countChar('"') % 2 == 1;
	}
	
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
		var quoteCounter = 0; // no tokens inside of strings
		while(c2 < s2.length && c1 <= s1.length - (s2.length - c2))
		{
			// trace(s1.charAt(c1), s2.charAt(c2));
			if(s1.charAt(c1) == '"')
				quoteCounter++;
			if(quoteCounter % 2 == 1) // an odd number of encountered quotes means we're inside a string constant
				c2 = 0; // break the ongoing match
			else
			{
				if(s1.charAt(c1) == s2.charAt(c2))
				{
					if(c2 == 0 && (c1 == 0 || !s1.charAt(c1 - 1).isTokenChar()))
						c2++;
					else if(c2 > 0)
						c2++;
				}
				else
					c2 = 0;
			}
			c1++;
		}
		return c2 == s2.length && (c1 + 1 >= s1.length || !s1.charAt(c1).isTokenChar(allowRight)) ? c1 : -1;
	}
	
	static public function hasOneOfTokens(s:String, a:Array<String>) : {result:Bool, token:String, pos:Int}
	{
		for(t in a)
		{
			var o = s.indexOfToken(t);
			if(o > -1)
				return {result:true, token:t, pos:o - t.length};
		}
		return {result:false, token:null, pos:-1};
	}
	
	static public function getNextToken(s:String, c:Int, allowRight:String = "") : {token:String, nextPos:Int} // c is the starting index
	{
		var r = "";
		var quoteCounter = 0;
		
		while((!s.charAt(c).isTokenChar() || quoteCounter % 2 == 1) && c < s.length)
		{
			if(s.charAt(c) == '"')
				quoteCounter++;
			c++;
		}
		
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
	
	static public function nextTokenIsName(s:String, pos:Int) : Bool
	{
		while(s.isSpace(pos))
		{
			pos++;
			if(pos >= s.length)
				return false;
		}
		return isTokenChar(s.charAt(pos));
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
			var v:Variable = context.get(k);
			if(v.global)
				trace("Variable entry " + k + " -> " + v.newName + " w/ " + v.nameAllows);
			for(l in 0 ... lines.length)
			{
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
		
		// Do a final pass to change all remaining modName occurences with Main.outName
		var o:Int;
		for(l in 0 ... lines.length)
			while((o = lines[l].indexOfToken(modName)) > -1)
				lines[l] = lines[l].substr(0, o - modName.length) + Main.outName + lines[l].substr(o);
		
		return lines;
	}
	
	// Analyzes the Lua lines to find all global variables and functions
	// Those are the one that will need replacement
	static private function buildContext()
	{
		var blockCounter:Int = 0;
		
		context = new Map<String, Variable>();
		
		for(l in 0 ... lines.length)
		{
			// Check for a = sign in an assignation (discard tests)
			var o = lines[l].lastIndexOf("=");
			if(o > -1)
			{
				if("<>~=".indexOf(lines[l].charAt(o-1)) == -1)
				{
					// We have an assignation
					if((o = lines[l].indexOfToken("local")) > -1) // detects a local variable
					{
						var r = lines[l].getNextToken(o);
						var varname = r.token;
						if(!context.exists(varname))
						{
							var v = new Variable(varname, modName + "_" + varname, blockCounter == 0);
							context.set(varname, v);
							trace("Registering " + (v.global ? "global " : "") + "variable " + v.oldName + " -> " + v.newName);
							trace(lines[l]);
						}
					}
					else // detects generic assignation
					{
						var r = lines[l].getNextToken(0);
						if(r.token != null)
						{
							var varname = r.token;
							// See if we find a = sign right away
							if(lines[l].charAt(lines[l].skipSpaces(r.nextPos)) == "=" && !context.exists(varname))
							{
								var v = new Variable(varname, modName + "_" + varname, true);
								context.set(varname, v);
								trace("Registering " + (v.global ? "global " : "") + "variable " + v.oldName + " -> " + v.newName);
								trace(lines[l]);
							}
						}
					}
				}
			}
			else if((o = lines[l].indexOfToken("function")) > -1 && !lines[l].hasTokenInStringConstant("function", o) && lines[l].nextTokenIsName(o)) // detects a function and local function
			{
				var varname = lines[l].getNextToken(o, ".:").token;
				var s = varname.split(":");
				var v = new Variable(varname,
									s[0] == modName ? Main.outName + ":" + s[0] + "_" + s[1] : modName + "_" + varname,
									lines[l].indexOfToken("local") > -1 ? blockCounter == 0 : true, ".:");
				context.set(varname, v);
				var os = v.oldName.replace(":", ".");
				var ns = v.newName.replace(":", ".");
				context.set(os, new Variable(os, ns, v.global, ".:"));
				if(varname == "ai")
					trace("Adding function ai on line : " + lines[l]);
			}
			else if((o = lines[l].indexOfToken("local")) > -1) // detects a valueless local variable initialization (ugh Lua why)
			{
				var varname = lines[l].getNextToken(o).token;
				var v = new Variable(varname, modName + "_" + varname, blockCounter == 0);
				context.set(varname, v);
			}
			
			var r = lines[l].hasOneOfTokens(["function", "if", "do"]);
			if(r.result && !lines[l].hasTokenInStringConstant(r.token, r.pos)) // detects the start of a block
			{
				trace("Starting block :");
				trace(lines[l]);
				blockCounter++;
			}
			else if(lines[l].indexOfToken("end") > -1) // detects the end of a blck
			{
				trace("Ending block");
				blockCounter--;
				trace("Now on block " + blockCounter);
			}
		}
			/*
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
		*/
	}
}
