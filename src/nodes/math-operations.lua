local node = require "node"

local function mk_node(x, y)
	return node {
		name    = "Operations",
		x       = x,
		y       = y,
		inputs  = {
			{
				label = "Number 1",
				type  = "number"
			}, {
				label = "Number 2",
				type  = "number"
			},
		},
		outputs = {
			{
				label = "Add",
				type  = "number"
			},
			{
				label = "Subtract",
				type  = "number"
			},
			{
				label = "Multiply",
				type  = "number"
			},
			{
				label = "Divide",
				type  = "number"
			}
		},
		values = {
			0,
			0
		},
		evaluate = function(self)
			return
				self.values[1] + self.values[2],
				self.values[1] - self.values[2],
				self.values[1] * self.values[2],
				self.values[1] / self.values[2]
		end
	}
end

return {
	name     = "Operations",
	category = "Math",
	new      = mk_node
}
