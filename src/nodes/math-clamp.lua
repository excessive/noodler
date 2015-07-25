local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		name    = "Clamp",
		x       = x,
		y       = y,
		inputs  = {
			{
				label = "Number",
				type  = "number"
			},
			{
				label = "Min",
				type  = "number"
			},
			{
				label = "Max",
				type  = "number"
			}
		},
		outputs = {
			{
				label = "Number",
				type  = "number"
			}
		},
		values = {
			0,
			0,
			0
		},
		evaluate = function(self)
			return
				cpml.utils.clamp(self.values[1], self.values[2], self.values[3])
		end
	}
end

return {
	name     = "Clamp",
	category = "Math",
	new      = mk_node
}
