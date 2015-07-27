local file = ...
local node = require "node"

local function mk_node(x, y)
	return node {
		file    = file,
		name    = "Logarithm",
		x       = x,
		y       = y,
		inputs  = {
			{
				label = "Number",
				type  = "number"
			}
		},
		outputs = {
			{
				label = "Exp",
				type  = "number"
			},
			{
				label = "Log",
				type  = "number"
			},
			{
				label = "Log10",
				type  = "number"
			}
		},
		values = {
			0
		},
		evaluate = function(self)
			return
				math.exp(self.values[1]),
				math.log(self.values[1]),
				math.log10(self.values[1])
		end
	}
end

return {
	name     = "Logarithm",
	category = "Math",
	new      = mk_node
}
