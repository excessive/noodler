local lume = require "lume"

local __NULL__ = function() end

local node    = {}
local node_mt = {}

local function new(params)
	assert(type(params.name) == "string", "'name' parameter is required.")
	if params.inputs then
		assert(type(params.inputs) == "table", "'inputs' parameter must be a table.")
	end
	if params.outputs then
		assert(type(params.outputs) == "table", "'outputs' parameter must be a table.")
	end
	local t = {
		uuid     = params.uuid or lume.uuid(),
		name     = assert(params.name),
		inputs   = params.inputs or {},
		outputs  = params.outputs or {},
		defaults = params.defaults or {},
		computed = {},
		fn       = params.fn or __NULL__
	}
	-- node input values
	if params.values then
		assert(type(params.values) == "table")
		t.values = params.values
	else
		t.values = {}
	end
	return setmetatable(t, node_mt)
end

function node:input(uuid)
	for _, v in ipairs(self.inputs) do
		if v.uuid == uuid then
			return v
		end
	end
	return false
end

function node:output(uuid)
	for _, v in ipairs(self.outputs) do
		if v.uuid == uuid then
			return v
		end
	end
	return false
end

function node:to_string()
	return string.format("Node: %s %s", self.name, self.uuid)
end

function node_mt.__call(_, ...)
	return new(...)
end

node_mt.__index    = node
node_mt.__tostring = node.to_string

return setmetatable({}, node_mt)
