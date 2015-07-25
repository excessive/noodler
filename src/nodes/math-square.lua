local node = require "node"

local function mk_node(x, y)
	return node {
		name    = "Square",
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
				label = "Square",
				type  = "number"
			},
			{
				label = "Sqrt",
				type  = "number"
			}
		},
		values = {
			0
		},
		evaluate = function(self)
			return
				self.values[1] * self.values[1],
				math.sqrt(self.values[1])
		end
	}
end

return {
	name     = "Square",
	category = "Math",
	new      = mk_node
}
