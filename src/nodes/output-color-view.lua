local file = ...
local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		file    = file,
		name    = "Color View",
		x       = x,
		y       = y,
		inputs  = {
			{
				label = "Color",
				type  = "color"
			}
		},
		values = {
			cpml.color(255, 255, 255, 255)
		},
		evaluate = function(self)
			-- print(self.values[1])
		end,
		display = function(self)
			love.graphics.setColor(love.math.gammaToLinear(self.values[1]))
			love.graphics.rectangle("fill", 0, 0, self.size.x, self.size.y)
		end,
		size = cpml.vec2(100, 80)
	}
end

return {
	name     = "Color View",
	category = "Output",
	new      = mk_node
}
