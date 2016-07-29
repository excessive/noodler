local lume = require "lume"

local plug = {}
local plug_mt = {}

local function new_plug(name, type)
	local t = {
		node   = false,
		uuid   = lume.uuid(),
		name   = name,
		type   = type
	}
	return setmetatable(t, plug_mt)
end

function plug:to_string()
	return string.format("Plug: %s %s %s (%s)", self.uuid, self.name, self.type, self.node.name)
end

plug_mt.__tostring = plug.to_string
plug_mt.__index = plug
plug_mt.__call = function(_, ...)
	return new_plug(...)
end

return setmetatable({}, plug_mt)
