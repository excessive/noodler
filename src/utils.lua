local cpml = require "cpml"

local function print_r(t, level)
	level = level or 0
	local indent = string.rep(" ", level * 2)
	for k, v in pairs(t) do
		print(string.format("%s%s (%s) = %s (%s)", indent, k, type(k), v, type(v)))
		if type(v) == "table" and not getmetatable(v) == cpml.color.new() then
			print_r(v, level + 1)
		end
	end
end

-- string 'r? I hardly knew 'r!
local function string_r(t, str, level)
	level = level or 0
	local indent = string.rep(" ", level * 2)
	str = (str or "")
	for k, v in pairs(t) do
		str = str .. (string.format("%s%s (%s) = %s (%s)", indent, k, type(k), v, type(v))) .. "\n"
		if type(v) == "table" and not getmetatable(v) == cpml.color.new() then
			str = string_r(v, str, level + 1)
		end
	end
	return str
end

return {
	print_r = print_r,
	string_r = string_r
}
