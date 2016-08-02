package.path = package.path .. ";libs/?.lua;libs/?/init.lua"
package.path = package.path .. ";src/?.lua;src/?/init.lua"

local node = require "node"
local graph = require "graph"
local plug = require "plug"
local cpml = require "cpml"

describe("Node graph", function()
	it("should compile", function()
		local g = graph()

		local n1 = node {
			name = "Input node",
			outputs = { plug("Value", "number", 1) },
			values = { 5 },
			evaluate = function(self)
				self.computed[1] = self.values[1] -- fixme: no evaluate should pass through values
			end
		}
		local n2 = node {
			name = "Math node",
			inputs = { plug("Value", "number", 1) },
			outputs = { plug("Value", "number", 1) },
			values = { 1 },
			evaluate = function(self)
				self.computed[1] = self.values[1] * 2
			end
		}
		local out = node {
			name = "Output node",
			inputs = { plug("Value", "number", 1) },
			values = { 0 },
			evaluate = function(self)
				print(self.values[1])
			end
		}

		for _, n in ipairs { n1, n2, out } do
			g:add(n, cpml.vec2())
		end

		g:connect(n1.outputs[1], n2.inputs[1])
		g:connect(n2.outputs[1], out.inputs[1])
		
		g:compile()
		g:execute()
	end)
end)