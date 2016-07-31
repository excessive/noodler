local node = require "node"
local plug = require "plug"
local cpml = require "cpml"

return {
	name     = "Mix",
	category = "Math",
	new      =  function(tree, position)
		return tree:add(
			node {
				name = "Mix",
				inputs = {
					plug("Factor", "number", 1),
					plug("Value", "number", 2),
					plug("Value", "number", 3)
				},
				outputs = {
					plug("Value", "number", 1)
				},
				values = {
					0.5,
					1.0,
					1.0
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
