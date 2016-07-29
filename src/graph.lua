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

	table.insert(self.connections, wire)

	return wire
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
end

function graph:execute()
	print("hello", self)
end

graph_mt.__index = graph
graph_mt.__call  = function(_, ...)
	return new(...)
end

return setmetatable({}, graph_mt)
