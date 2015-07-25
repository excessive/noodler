local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		name    = "Boolean to Number",
		x       = x,
		y       = y,
		inputs  = {
			{
				label = "Boolean",
				type  = "boolean"
			}
		},
		outputs = {
			{
				label = "Number",
				type  = "number"
			}
		},
		values = {
			false
		},
		evaluate = function(self)
			print("help", self.values[1])
			return (self.values[1] == true and 1 or 0)
		end
	}
end

return {
	name     = "Boolean to Number",
	category = "Convert",
	new      = mk_node
}
