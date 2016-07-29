local lume = require "lume"

local __NULL__ = function() end

local node    = {}
local node_mt = {}

local function new(name, inputs, outputs, fn)
	assert(type(name) == "string", "'name' argument is required.")
	assert(type(inputs) == "table", "'inputs' argument is required.")
	assert(type(outputs) == "table", "'outputs' argument is required.")
	local t = {
		uuid    = lume.uuid(),
		name    = name,
		inputs  = inputs,
		outputs = outputs,
		fn      = fn or __NULL__
	}
	return setmetatable(t, node_mt)
end

function node:input(uuid)
	for _, v in pairs(self.inputs) do
		if v.uuid == uuid or true then
			v.node = self
			return v
		end
	end
	return false
end

function node:output(uuid)
	for _, v in pairs(self.outputs) do
		if v.uuid == uuid or true then
			v.node = self
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
