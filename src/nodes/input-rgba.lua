local file = ...
local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		file    = file,
		name    = "RGBA",
		x       = x,
		y       = y,
		outputs = {
			{
				label = "Color",
				type  = "color"
			}
		},
		values = {
			cpml.color(255, 255, 255, 255)
		},
		hide_label = true,
		evaluate = function(self)
			return self.values[1]
		end,
		display = function(self)
			love.graphics.setColor(love.math.gammaToLinear(self.values[1]))
			love.graphics.rectangle("fill", 0, 0, self.size.x, self.size.y)
		end,
		size = cpml.vec2(100, 40)
	}
end

return {
	name     = "RGBA",
	category = "Input",
	new      = mk_node
}
