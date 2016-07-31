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
	note = function(tree, position)
		return tree:add(
			node {
				name = "Note"
			},
			position
		)
	end,
	value = function(tree, position)
		return tree:add(
			node {
				name = "Value",
				outputs = {
					plug("Value", "number", 1)
				},
				evaluate = function(self)
					self.computed[1] = math.random()
				end
			},
			position
		)
	end,
	mix = function(tree, position)
		return tree:add(
			node {
				name = "Mix",
				inputs = {
					plug("Factor", "number", 1),
					plug("Value", "number", 2),
					plug("Value", "number", 3)
				},
				outputs = {
					plug("Value", "number", 1)
				},
				values = {
					0.5,
					0.0,
					1.0
				},
				evaluate = function(self)
					self.computed[1] = cpml.utils.lerp(
						self.values[1],
						self.values[2],
						self.values[3]
					)
				end
			},
			position
		)
	end,
	number_view = function(tree, position)
		return tree:add(
			node {
				name = "Number View",
				inputs = {
					plug("Value", "number", 1)
				},
				values = {
					0
				},
				evaluate = function(self)
					print(self.values[1])
				end
			},
			position
		)
	end
}

local tree = graph()
-- tree.debug = true

local a = nodes.value(tree, cpml.vec2(-400, -250))
local b = nodes.value(tree, cpml.vec2(-400,   50))

local m = nodes.mix(tree, cpml.vec2(-100, -100))

local o = nodes.number_view(tree, cpml.vec2(200, -100))

local wire1 = tree:connect(a.outputs[1], m.inputs[2])
local wire2 = tree:connect(b.outputs[1], m.inputs[3])
local wire3 = tree:connect(m.outputs[1], o.inputs[1])

local function dump_wire(wire, tag)
	if not wire then
		print(string.format(
			"BAD WIRE: %s", tag
		))
		return
	end
	print(string.format(
		"\n%s\nFROM\t%s\nTO\t%s\nAS\t%s\n",
		tag,
		wire.input,
		wire.output,
		wire.input.type
	))
end

if tree.debug then
	dump_wire(wire1, "a->m")
	dump_wire(wire2, "b->m")
	dump_wire(wire3, "m->o")
end

tree:compile()
tree:execute()

function love.draw()
	local lume = require "lume"
	local w, h = love.graphics.getDimensions()
	local width = w - 50
	local pos = lume.pingpong(love.timer.getTime() / 3)
	pos = lume.smooth(0, width, pos)
	love.graphics.setColor(80, 80, 80, 255)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 3)
	love.graphics.setColor(220, 220, 220, 255)
	love.graphics.rectangle("fill", pos, 0, 50, 3)

	love.graphics.push()
	love.graphics.origin()
	love.graphics.translate(w/2, h/2)
	for _, n in ipairs(tree) do
		local position = tree.positions[n.uuid]
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.rectangle("fill", position.x, position.y, 150, 200)
		love.graphics.setColor(200, 200, 200, 255)
		love.graphics.rectangle("fill", position.x, position.y, 150, 25)
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.print(n.name, position.x + 6, position.y + 6)
	end
	love.graphics.pop()
end
