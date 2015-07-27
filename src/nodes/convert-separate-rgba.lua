local file = ...
local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		file    = file,
		name    = "Separate RGBA",
		x       = x,
		y       = y,
		inputs  = {
			{
				label = "Color",
				type  = "color"
			}
		},
		outputs = {
			{
				label = "R",
				type  = "number"
			}, {
				label = "G",
				type  = "number"
			}, {
				label = "B",
				type  = "number"
			}, {
				label = "A",
				type  = "number"
			}
		},
		values = {
			cpml.color(0, 0, 0, 255)
		},
		evaluate = function(self)
			return self.values[1][1], self.values[1][2], self.values[1][3], self.values[1][4]
		end
	}
end

return {
	name     = "Separate RGBA",
	category = "Convert",
	new      = mk_node
}
