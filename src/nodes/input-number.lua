local node = require "node"
local plug = require "plug"

return {
	name     = "Number",
	category = "Input",
	new      = function(tree, position)
		return tree:add(
			node {
				name = "Value",
				outputs = {
					plug("Value", "number", 1)
				},
				values = {
					1
				},
				display = function(self)
					love.graphics.setColor(255, 255, 255, 255)
					love.graphics.rectangle("fill", 0, 0, self.size.x, self.size.y)
					love.graphics.setColor(0, 0, 0, 255)
					love.graphics.print(tostring(self.values[1]), 5)
				end,
				evaluate = function(self)
					self.computed[1] = self.values[1]
				end
			},
			position
		)
	end
}
