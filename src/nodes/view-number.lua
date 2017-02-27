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
				display = function(self, ui)
					ui:label(string.format("%5.5f", self.values[1]))
				end
			},
			position
		)
	end
}
