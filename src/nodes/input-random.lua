local node = require "node"
local cpml = require "cpml"

local function mk_node(x, y)
	return node {
		name    = "Random",
		x       = x,
		y       = y,
		inputs   = {
			{
				label = "Seed",
				type  = "number"
			}
		},
		outputs  = {
			{
				label = "Number",
				type  = "number"
			}
		},
		values = {
			-1
		},
		display = function(self) end,
		evaluate = function(self)
			if self.values[1] == -1 then
				love.math.setRandomSeed(love.timer.getTime())
			else
				love.math.setRandomSeed(self.values[1])
			end
			return love.math.random()
		end
	}
end

return {
	name     = "Random",
	category = "Input",
	new      = mk_node
}
