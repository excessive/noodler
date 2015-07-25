# Noodler
A general purpose node system for LÖVE games.

This project is very early, but should be usable at all times.

`src/node.lua` should be usable in any project and depends only on
[CPML](https://github.com/excessive/cpml) and
[lume](https://github.com/rxi/lume).

`src/nodes` contains numerous general purpose/example nodes.

The demo requires LÖVE 0.10 and sRGB support. The node evaluation should run
on Lua 5.1+ as long as you don't call draw on them.

<a href="https://www.irccloud.com/invite?channel=%23excessive&amp;hostname=irc.oftc.net&amp;port=6697&amp;ssl=1" target="_blank"><img src="https://www.irccloud.com/invite-svg?channel=%23excessive&amp;hostname=irc.oftc.net&amp;port=6697&amp;ssl=1"  height="18"></a>

LÖVE 0.10 nightlies for Windows can be found [here](https://ci.appveyor.com/project/AlexSzpakowski/love/build/artifacts).

## Defining new nodes
```lua
local cpml = require "cpml"
local node = require "node"

node {
	-- The title displayed.
	name = "Example Node",
	-- The node position - this will default to 0, 0.
	x = 20,
	y = 20,
	-- Define as many inputs as you want, with any type name.
	-- The types are not validated - you are expected to write well-behaved code.
	inputs = {
		{ label = "Example Color", type = "color" },
		{ label = "Example Number", type = "number" }
	},
	-- You may have any number of outputs, and you must return the same number of
	-- values from evaluate as declared here.
	outputs = {
		{ label = "Output", type = "vector" }
	},
	-- You must define a default value for every input declared.
	values = {
		cpml.color(0, 0, 0, 255),
		1
	},
	evaluate = function(self)
		return cpml.vec3(
			self.values[1][1] * self.values[2],
			self.values[1][2] * self.values[2],
			self.values[1][3] * self.values[2]
		)
	end
}
```

For further examples, have a look in `src/nodes`.

## License
MIT. See LICENSE.md
