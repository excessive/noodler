local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		name    = "Sin",
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
				label = "Sin",
				type  = "number"
			},
			{
				label = "Sinh",
				type  = "number"
			},
			{
				label = "Asin",
				type  = "number"
			}
		},
		values = {
			0
		},
		evaluate = function(self)
			return
				math.sin(self.values[1]),
				math.sinh(self.values[1]),
				math.asin(self.values[1])
		end
	}
end

return {
	name     = "Sin",
	category = "Trigonometry",
	new      = mk_node
}
