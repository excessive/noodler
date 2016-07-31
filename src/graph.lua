local cpml = require "cpml"

local graph = {}
local graph_mt = {}

local function new()
	local t = {
		debug       = false,
		connections = {},
		positions   = {},
		program     = {}
	}
	return setmetatable(t, graph_mt)
end

function graph:add(node, position)
	assert(cpml.vec2.is_vec2(position))
	self.positions[node.uuid] = position
	for _, plug in ipairs(node.inputs) do
		plug.node = node
	end
	for _, plug in ipairs(node.outputs) do
		plug.node = node
	end
	table.insert(self, node)
	return node
end

function graph:connect(from, to)
	-- only allow connecting nodes of the same type, so we don't have to think
	-- about implicit type conversions.
	if from.type ~= to.type then
		return false
	end

	-- note: the inputs and outputs are *plugs*, not id's or nodes.
	local wire = {
		input  = from,
		output = to
	}

	self.connections[to] = wire

	return wire
end

local function trace(self, node, depth)
	if self.debug then
		print(depth, node.name)
	end
	self.program[depth] = self.program[depth] or {}
	table.insert(self.program[depth], node)
	for _, plug in ipairs(node.inputs) do
		local next_wire = self.connections[plug]
		if next_wire then
			trace(self, next_wire.input.node, depth + 1)
		end
	end
end

function graph:compile()
	local outputs = {}
	for _, node in ipairs(self) do
		if #node.outputs == 0 then
			table.insert(outputs, node)
			if self.debug then
				print("Found an output node", node)
			end
		end
	end
	if #outputs == 0 then
		print("WARNING: No output nodes!")
		return false, "Missing output node"
	end

	self.program = {}
	for _, node in ipairs(outputs) do
		trace(self, node, 1)
	end

	return true
end

function graph:execute()
	for i=#self.program, 1, -1 do
		for _, node in ipairs(self.program[i]) do
			if self.debug then
				print(node.name)
			end
			for _, p in ipairs(node.inputs) do
				if self.connections[p] then
					local wire = self.connections[p]
					node.values[wire.output.index] = wire.input.node.computed[wire.input.index]
				end
			end
			node:fn()
			if self.debug then
				for j, v in ipairs(node.computed) do
					print(j, v)
				end
			end
		end
	end
end

graph_mt.__index = graph
graph_mt.__call  = function(_, ...)
	return new(...)
end

return setmetatable({}, graph_mt)
