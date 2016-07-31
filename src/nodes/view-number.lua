local node = require "node"
local plug = require "plug"

return {
	name     = "Number",
	category = "View",
	new      = function(tree, position)
		return tree:add(
			node {
				name    = "Number View",
				inputs  = {
					plug("Value", "number", 1)
				},
				values = {
					0
				},
				evaluate = function(self)
					print(self.values[1])
				end,
				display = function(self)
					love.graphics.setColor(255, 255, 255, 255)
					love.graphics.rectangle("fill", 0, 0, self.size.x, self.size.y)
					love.graphics.setColor(0, 0, 0, 255)
					love.graphics.print(string.format("%5.5f", self.values[1]), 5)
				end
			},
			position
		)
	end
}
