local file = ...
local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		file    = file,
		name    = "Tan",
		x       = x,
		y       = y,
		inputs  = {
			{
				label = "X",
				type  = "number"
			},
			{
				label = "Y",
				type  = "number"
			}
		},
		outputs = {
			{
				label = "Tan",
				type  = "number"
			},
			{
				label = "Tanh",
				type  = "number"
			},
			{
				label = "Atan",
				type  = "number"
			},
			{
				label = "Atan2",
				type  = "number"
			}
		},
		values = {
			0,
			0
		},
		evaluate = function(self)
			return
				math.tan(self.values[1]),
				math.tanh(self.values[1]),
				math.atan(self.values[1]),
				math.atan2(self.values[2], self.values[1])
		end
	}
end

return {
	name     = "Tan",
	category = "Trigonometry",
	new      = mk_node
}
