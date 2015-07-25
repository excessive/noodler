local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		name    = "Separate XYZ",
		x       = x,
		y       = y,
		inputs  = {
			{
				label = "Vector",
				type  = "vector"
			}
		},
		outputs = {
			{
				label = "X",
				type  = "number"
			}, {
				label = "Y",
				type  = "number"
			}, {
				label = "Z",
				type  = "number"
			}
		},
		values = {
			cpml.vec3(0, 0, 0)
		},
		evaluate = function(self)
			return self.values[1].x, self.values[1].y, self.values[1].z
		end
	}
end

return {
	name     = "Separate XYZ",
	category = "Convert",
	new      = mk_node
}
