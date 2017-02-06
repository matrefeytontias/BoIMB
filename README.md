# Binding of Isaac Modpack Builder

BoIMB is a tool that allows packaging of modpacks for The Binding of Isaac Afterbirth+, that is, mods that rely on many smaller mods.
Because of the current restrictions on Lua mods for Afterbirth+, all of the code for a mod has to stay in one single main.lua file, the usage
of the `require` function being forbidden. This tool allows for modpacks to be structured as a directories tree that is then merged into one
single, huge main.lua file that will satisfy the game's mod loader. It also allows for local files to be included via a restricted `require`.

## Usage

Individual mods are written exactly like usual Afterbirth+ mods would. A direct consequence is that standalone mods can be instantly integrated in a modpack.

BoIMB recursively visits every directory and subdirectory starting from its own directory. It then grabs every main.lua file it can find,
processes them as needed, packs the resources (namely, `content` and `resources` directories) and builds a big mod in a given directory which then
contains valid main.lua, `content` and `resources` files and directories. The output directory is passed as an argument to the program.

## Example usage

```
BoIMB.exe
pills
-- pill1
-- -- content
-- -- -- pocketitems.xml
-- -- main.lua (uses require("stuff"))
-- -- stuff.lua
-- pill2
-- -- content
-- -- -- pocketitems.xml
-- -- main.lua
items
-- item1
-- -- content
-- -- -- items.xml
-- -- resources
-- -- -- gfx
-- -- -- -- Collectible
-- -- -- -- -- item1_boop.png
-- -- main.lua (uses require("thing"))
-- -- thing.lua
```

Then run `BoIMB "The Big Mod" . BigMod`, and the tool will assemble all the files into a working mod called BigMod which will register as "The Big Mod". You can then
copy the generated BigMod directory into your Afterbirth+ mods directory.

## Handling name collisions

Because of the fact that the tool is merging text, files and directories, collisions are very likely to happen, that is, trying to handle two or more
entities (be it Lua variables or files) with the same name. While this isn't a problem as long as the two entities are in different environments
(files or directories respectively), this becomes a problem when brought into the same environment, which is what this tool does. This tool plans for
some cases and brings a solution to them.

### Lua functions and global variables

Lua files meant to be used with BoIMB still need the `RegisterMod` line. This line is actually removed by the tool, but the registered mod's name is
used to avoid collisions between variables and functions defined in every file's global scope (this is a problem because files get merged). Here's an
example of what it does.

```Lua
local mod1 = RegisterMod("My Soops Good Mod", 1) -- no argument is actually necessary
local mod1 = RegisterMod() -- this works all the same, with BoIMB

local flag = true

function bleh()
	foobar()
end

function mod1:doTheThing(blah, bleh, bloo)
	bleh()
end
```
Once processed by the tool, this code becomes the following, assuming the output name given to BoIMB is BigMod :
```Lua
local mod1_flag = true

function mod1_bleh()
	foobar()
end

function BigMod:mod1_doTheThing(blah, bleh, bloo)
	mod1_bleh()
end
```
Because of how this works, you are not allowed to name two registered mods with the same name, and compilation will fail if you do so.

### Resource files

Because resource files are created by an external program and can be referenced many times in code, it is up to the user to make sure that collisions
can't happen - the tool will still give an error if a collision is detected and abort compilation.