local file = ...
local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		file    = file,
		name    = "Angles",
		x       = x,
		y       = y,
		inputs  = {
			{
				label = "Angle",
				type  = "number"
			}
		},
		outputs = {
			{
				label = "Radian",
				type  = "number"
			},
			{
				label = "Degree",
				type  = "number"
			}
		},
		values = {
			0
		},
		evaluate = function(self)
			return
				math.rad(self.values[1]),
				math.deg(self.values[1])
		end
	}
end

return {
	name     = "Angles",
	category = "Convert",
	new      = mk_node
}
