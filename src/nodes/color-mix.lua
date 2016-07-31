local node = require "node"
local plug = require "plug"
local cpml = require "cpml"

return {
	name     = "Mix",
	category = "Color",
	new      =  function(tree, position)
		return tree:add(
			node {
				name = "Mix",
				inputs = {
					plug("Factor", "number", 1),
					plug("Value", "color", 2),
					plug("Value", "color", 3)
				},
				outputs = {
					plug("Value", "color", 1)
				},
				values = {
					0.5,
					{ 255, 255, 255, 255 },
					{ 255, 255, 255, 255 }
				},
				evaluate = function(self)
					self.computed[1] = cpml.color.lerp(
						self.values[1],
						self.values[2],
						self.values[3]
					)
				end
			},
			position
		)
	end
}
