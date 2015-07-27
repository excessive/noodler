local file = ...
local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		file    = file,
		name    = "Cos",
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
				label = "Cos",
				type  = "number"
			},
			{
				label = "Cosh",
				type  = "number"
			},
			{
				label = "Acos",
				type  = "number"
			}
		},
		values = {
			0
		},
		evaluate = function(self)
			return
				math.cos(self.values[1]),
				math.cosh(self.values[1]),
				math.acos(self.values[1])
		end
	}
end

return {
	name     = "Cos",
	category = "Trigonometry",
	new      = mk_node
}
