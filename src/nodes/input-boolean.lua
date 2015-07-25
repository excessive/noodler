local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		name    = "Boolean",
		x       = x,
		y       = y,
		outputs  = {
			{
				label = "True",
				type  = "boolean"
			},
			{
				label = "False",
				type  = "boolean"
			}
		},
		values = {
			true, false
		},
		evaluate = function(self)
			return self.values[1], self.values[2]
		end
	}
end

return {
	name     = "Boolean",
	category = "Input",
	new      = mk_node
}
