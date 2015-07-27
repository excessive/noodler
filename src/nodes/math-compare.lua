local file = ...
local node = require "node"

local function mk_node(x, y)
	return node {
		file    = file,
		name    = "Compare",
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
				label = "==",
				type  = "boolean"
			},
			{
				label = ">",
				type  = "boolean"
			},
			{
				label = ">=",
				type  = "boolean"
			},
			{
				label = "<",
				type  = "boolean"
			},
			{
				label = "<=",
				type  = "boolean"
			}
		},
		values = {
			0,
			0
		},
		evaluate = function(self)
			return
				self.values[1] == self.values[2],
				self.values[1] >  self.values[2],
				self.values[1] >= self.values[2],
				self.values[1] <  self.values[2],
				self.values[1] <= self.values[2]
		end
	}
end

return {
	name     = "Compare",
	category = "Math",
	new      = mk_node
}
