local node = require "node"

local function mk_node(x, y)
	return node {
		name    = "Modulo",
		x       = x,
		y       = y,
		inputs  = {
			{
				label = "Numerator",
				type  = "number"
			},
			{
				label = "Denominator",
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
				math.fmod(self.values[1], self.values[2])
		end
	}
end

return {
	name     = "Modulo",
	category = "Math",
	new      = mk_node
}
