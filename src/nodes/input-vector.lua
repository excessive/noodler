local file = ...
local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		file    = file,
		name    = "Vector",
		x       = x,
		y       = y,
		outputs = {
			{
				label = "Vector",
				type  = "vector"
			}
		},
		values = {
			0,
			0,
			0
		},
		evaluate = function(self)
			return cpml.vec3(self.values[1], self.values[2], self.values[3])
		end,
	}
end

return {
	name     = "Vector",
	category = "Input",
	new      = mk_node
}
