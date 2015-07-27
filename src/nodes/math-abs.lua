local file = ...
local node = require "node"

local function mk_node(x, y)
	return node {
		file    = file,
		name    = "Absolute",
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
				label = "Number",
				type  = "number"
			}
		},
		values = {
			0
		},
		evaluate = function(self)
			return
				math.abs(self.values[1])
		end
	}
end

return {
	name     = "Absolute",
	category = "Math",
	new      = mk_node
}
