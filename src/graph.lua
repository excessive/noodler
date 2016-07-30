local graph = {}
local graph_mt = {}

local function new()
	local t = {
		connections = {}
	}
	return setmetatable(t, graph_mt)
end

function graph:connect(from, to)
	-- only allow connecting nodes of the same type, so we don't have to think
	-- about implicit type conversions.
	if from.type ~= to.type then
		return false
	end

	local wire = {
		input  = from,
		output = to,
		type   = from.type
	}

	self.connections[to] = wire

	return wire
end

local function trace(self, node, depth)
	print(depth, node.name)
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
			print("Found an output node", node)
		end
	end
	if #outputs == 0 then
		print("WARNING: No output nodes!")
		return
	end

	for _, node in ipairs(outputs) do
		trace(self, node, 0)
	end
end

function graph:execute()
	print("hello", self)
end

graph_mt.__index = graph
graph_mt.__call  = function(_, ...)
	return new(...)
end

return setmetatable({}, graph_mt)
