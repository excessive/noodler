local file = ...
local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		file    = file,
		name    = "Number View",
		x       = x,
		y       = y,
		inputs  = {
			{
				label = "Number",
				type  = "number"
			}
		},
		values = {
			0
		},
		evaluate = function(self) end,
		display = function(self)
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.rectangle("fill", 0, 0, self.size.x, self.size.y)
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.print(string.format("%5.5f", self.values[1]), 5)
		end,
		size = cpml.vec2(100, 20)
	}
end

return {
	name     = "Number View",
	category = "Output",
	new      = mk_node
}
