local node = require "node"
local plug = require "plug"

return {
	name     = "Number",
	category = "Input",
	new      = function(tree, position)
		return tree:add(
			node {
				name = "Value",
				outputs = {
					plug("Value", "number", 1)
				},
				values = {
					1
				},
				display = function(self, ui)
					local t = {
						value = tostring(self.values[1]),
						convert = tonumber
					}
					local state, changed = ui.edit("field", t)
					-- todo: store temp, use state == "commited"
					if changed then
						self.values[1] = t.convert(t.value) or 0.0
						return true
					end
				end,
				evaluate = function(self)
					self.computed[1] = self.values[1]
				end
			},
			position
		)
	end
}
