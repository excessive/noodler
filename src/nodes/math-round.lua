local file = ...
local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		file    = file,
		name    = "Round",
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
				label = "Round",
				type  = "number"
			},
			{
				label = "Ceil",
				type  = "number"
			},
			{
				label = "Floor",
				type  = "number"
			}
		},
		values = {
			0
		},
		evaluate = function(self)
			return
				cpml.utils.round(self.values[1]),
				math.ceil(self.values[1]),
				math.floor(self.values[1])
		end
	}
end

return {
	name     = "Round",
	category = "Math",
	new      = mk_node
}
