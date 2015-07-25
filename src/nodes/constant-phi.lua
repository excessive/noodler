local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		name    = "Phi",
		x       = x,
		y       = y,
		outputs  = {
			{
				label = "Phi",
				type  = "number"
			}
		},
		values = {
			(1+math.sqrt(5))/2,
		},
		hide_label = false,
		evaluate = function(self)
			return self.values[1]
		end,
	}
end

return {
	name     = "Phi",
	category = "Constant",
	new      = mk_node
}
