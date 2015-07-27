local file = ...
local node = require "node"

local function mk_node(x, y)
	return node {
		file    = file,
		name    = "Modulo Factor",
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
				label = "Integer",
				type  = "number"
			},
			{
				label = "Decimal",
				type  = "number"
			}
		},
		values = {
			0
		},
		evaluate = function(self)
			return
				math.modf(self.values[1])
		end
	}
end

return {
	name     = "Modulo Factor",
	category = "Math",
	new      = mk_node
}
