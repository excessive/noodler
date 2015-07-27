local file = ...
local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		file    = file,
		name    = "Time",
		x       = x,
		y       = y,
		outputs  = {
			{
				label = "Number",
				type  = "number"
			}
		},
		values = {
			0
		},
		hide_label = true,
		evaluate = function(self)
			return love.timer.getTime()
		end,
		display = function(self)
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.rectangle("fill", 0, 0, self.size.x, self.size.y)
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.print(tostring(self.values[1]), 5)
		end,
		size = cpml.vec2(100, 20)
	}
end

return {
	name     = "Time",
	category = "Input",
	new      = mk_node
}
