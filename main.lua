local cpml  = require "cpml"
local graph = require "graph"
local node  = require "node"
local plug  = require "plug"

function love.load()
	love.window.setMode(1280, 720, {
		msaa      = 4,
		resizable = true,
		vsync     = true
	})
	love.window.setTitle("Noodler")
	local bg = cpml.color.linear_to_gamma { 40, 40, 40, 255 }
	love.graphics.setBackgroundColor(bg)
end

local nodes = {
	note = function(tree)
		local v = node("Note", {}, {}, {})
		table.insert(tree, v)
		return v
	end,
	value = function(tree)
		local outputs = {
			plug("Value", "number")
		}
		local v = node("Value", {}, outputs, {})
		table.insert(tree, v)
		return v
	end,
	mix = function(tree)
		local inputs = {
			plug("Factor", "number"),
			plug("Value", "number"),
			plug("Value", "number")
		}
		local outputs = {
			plug("Value", "number")
		}
		local v = node("Mix", inputs, outputs, {})
		table.insert(tree, v)
		return v
	end,
	number_view = function(tree)
		local inputs = {
			plug("Value", "number")
		}
		local v = node("Number View", inputs, {}, {}, function(self)
			print(self.values[1])
		end)
		table.insert(tree, v)
		return v
	end
}

local tree = graph()
local a = nodes.value(tree)
local b = nodes.mix(tree)
print(a)

local c = nodes.number_view(tree)
print(c)

local wire1 = tree:connect(a:output(1), b:input(1))
local wire2 = tree:connect(b:output(1), c:input(1))

local function dump_wire(wire, tag)
	print(string.format(
		"\n%s\nFROM\t%s\nTO\t%s\nAS\t%s\n",
		tag,
		wire.input,
		wire.output,
		wire.type
	))
end

dump_wire(wire1, "a->b")
dump_wire(wire2, "b->c")

tree:compile()
tree:execute()

function love.draw()
	local lume = require "lume"
	local width = love.graphics.getWidth() - 50
	local pos = lume.pingpong(love.timer.getTime() / 3)
	pos = lume.smooth(0, width, pos)
	love.graphics.setColor(80, 80, 80, 255)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 3)
	love.graphics.setColor(220, 220, 220, 255)
	love.graphics.rectangle("fill", pos, 0, 50, 3)
end
