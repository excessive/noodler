local file = ...
local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		file    = file,
		name    = "Combine RGBA",
		x       = x,
		y       = y,
		inputs  = {
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
		outputs = {
			{
				label = "Color",
				type  = "color"
			}
		},
		values = {
			0, 0, 0, 255
		},
		evaluate = function(self)
			return cpml.color(self.values[1], self.values[2], self.values[3], self.values[4])
		end
	}
end

return {
	name     = "Combine RGBA",
	category = "Convert",
	new      = mk_node
}
