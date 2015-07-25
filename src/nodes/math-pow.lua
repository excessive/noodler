local node = require "node"

local function mk_node(x, y)
	return node {
		name    = "Exponent",
		x       = x,
		y       = y,
		inputs  = {
			{
				label = "Number",
				type  = "number"
			},
			{
				label = "Exponent",
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
			0
		},
		evaluate = function(self)
			return
				math.pow(self.values[1], self.values[2])
		end
	}
end

return {
	name     = "Exponent",
	category = "Math",
	new      = mk_node
}
