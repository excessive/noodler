local file = ...
local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		file    = file,
		name    = "Mix",
		x       = x,
		y       = y,
		inputs  = {
			{
				label = "Factor",
				type  = "number"
			}, {
				label = "Color 1",
				type  = "color"
			}, {
				label = "Color 2",
				type  = "color"
			},
		},
		outputs = {
			{
				label = "Color",
				type  = "color"
			}
		},
		values = {
			0.5,
			cpml.color(255, 255, 255, 255),
			cpml.color(255, 255, 255, 255)
		},
		evaluate = function(self)
			local factor = self.values[1]
			local color1 = self.values[2]
			local color2 = self.values[3]
			return cpml.color.lerp(color1, color2, factor)
		end
	}
end

return {
	name     = "Mix",
	category = "Color",
	new      = mk_node
}
