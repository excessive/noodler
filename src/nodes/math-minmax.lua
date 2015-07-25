local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		name    = "Min/Max",
		x       = x,
		y       = y,
		inputs  = {
			{
				label = "Number 1",
				type  = "number"
			},
			{
				label = "Number 2",
				type  = "number"
			}
		},
		outputs = {
			{
				label = "Min",
				type  = "number"
			},
			{
				label = "Max",
				type  = "number"
			}
		},
		values = {
			0,
			0
		},
		evaluate = function(self)
			return
				math.min(self.values[1], self.values[2]),
				math.max(self.values[1], self.values[2])
		end
	}
end

return {
	name     = "Min/Max",
	category = "Math",
	new      = mk_node
}
