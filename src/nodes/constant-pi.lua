local file = ...
local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		file    = file,
		name    = "Pi",
		x       = x,
		y       = y,
		outputs  = {
			{
				label = "Pi",
				type  = "number"
			}, {
				label = "2Pi",
				type  = "number"
			}
		},
		values = {
			math.pi,
			math.pi*2
		},
		hide_label = false,
		evaluate = function(self)
			return self.values[1], self.values[2]
		end,
	}
end

return {
	name     = "Pi",
	category = "Constant",
	new      = mk_node
}
