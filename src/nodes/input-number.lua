local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		name    = "Number",
		x       = x,
		y       = y,
		outputs  = {
			{
				label = "Number",
				type  = "number"
			}
		},
		values = {
			1
		},
		hide_label = true,
		evaluate = function(self)
			return self.values[1]
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
	name     = "Number",
	category = "Input",
	new      = mk_node
}
