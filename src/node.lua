local cpml = require "cpml"
local lume = require "lume"

local noodle = {}
noodle.__index = noodle

local function new(params)
	params = params or {}
	local t = {
		file            = params.file or "generic",
		name            = params.name or "Node",
		position        = cpml.vec2(params.x, params.y),
		inputs          = params.inputs or {},
		outputs         = params.outputs or {},
		invulnerable    = params.invulnerable or false,
		-- Note: Display function draw areas aren't enforced other than with
		-- scissoring - behave responsibly.
		display         = params.display or false,
		evaluate        = params.evaluate or false,
		hide_label      = params.hide_label or false,
		size            = params.size or cpml.vec2(),
		default_values  = params.values or {},
		values          = {},
		input_position  = {},
		output_position = {},
		data            = {},
		connections     = {},
		sources         = {},
		text_cache      = {},
		selected        = false,
		hit             = false,
		hit_connector   = false,
		needs_eval      = true,
		leader          = false
	}
	local ret = setmetatable(t, noodle)
	ret:reset_defaults()
	ret:update()

	return ret
end

local function is_node(node)
	return getmetatable(node) == noodle
end

function noodle:clone()
	local ret = new {
		x          = self.position.x,
		y          = self.position.y,
		name       = self.name,
		inputs     = self.inputs,
		outputs    = self.outputs,
		display    = self.display,
		evaluate   = self.evaluate,
		hide_label = self.hide_label,
		size       = self.size,
		values     = self.default_values,
	}
	ret:update()
	return ret
end

function noodle:reset_defaults()
	for i, value in ipairs(self.default_values) do
		if type(value) == "table" and value.clone then
			self.values[i] = value:clone()
		else
			self.values[i] = value
		end
	end
end

function noodle:set_value(socket, value)
	if type(value) == "table" then
		for k, v in pairs(value) do
			self.values[socket][k] = v
		end
	else
		self.values[socket] = value
	end
end

function noodle:set_values(values)
	for socket, value in ipairs(values) do
		self:set_value(socket, value)
	end
end

function noodle:connect(other, from, to)
	assert(is_node(other), "Invalid node")
	assert(self.outputs[from], "Invalid output")
	assert(other.inputs[to], "Invalid input")

	-- Can't connect to self.
	if other == self then
		return false
	end

	-- Make sure we only connect outputs to inputs of the same type.
	if other.inputs[to].type == self.outputs[from].type then
		local function check_looping(node)
			for k, con in pairs(node.connections) do
				for i, to in ipairs(con) do
					if to.node == self then
						return true
					end
					if check_looping(to.node) then
						return true
					end
				end
			end
			return false
		end

		-- A loop would make the algorithm unsolvable, don't let it happen.
		if check_looping(other) then
			return false
		end

		other.leader = self.leader or self
		if not self.connections[from] then
			self.connections[from] = {}
		end

		-- Remove anything that was previously connected to this socket
		if other.sources[to] then
			local node = other.sources[to].node
			for k, v in pairs(node.connections[from]) do
				if v.socket == to and v.node == other then
					table.remove(node.connections[from], k)
					break
				end
			end
		end

		-- Connect both ways for easy (enough) traversal
		-- Outputs can go to multiple places, but inputs can only come from one.
		other.sources[to] = { node = self, socket = from }
		table.insert(self.connections[from], { node = other, socket = to })

		-- Any connection or disconnection invalidates the tree.
		self.needs_eval = true

		return true
	else
		return false
	end
end

function noodle:disconnect(socket, all)
	print("Disconnecting " .. (socket or "all"))
	local function dc(socket)
		local input = self.sources[socket]
		local cons = input.node.connections[input.socket]
		for i, to in ipairs(cons) do
			if to.node == self then
				table.remove(cons, i)
				self.sources[socket] = nil
				-- If we got rid of the last input source, promote to leader so that
				-- noodles still get drawn from this point on.
				if lume.count(self.sources) == 0 then
					self.leader = false
				end
				self:reset_defaults()
				self.needs_eval = true
				break
			end
		end
	end
	if all then
		for socket, _ in pairs(self.sources) do
			dc(socket)
		end
	elseif self.sources[socket] then
		dc(socket)
	end
end

function noodle:update()
	local i        = 1
	local spacing  = 20
	local width    = 10
	local offset   = self.hide_label and 0 or self.size.y
	if offset > 0 then
		offset = offset + 5
	end

	-- +100px for inputs and outputs
	if #self.inputs > 0 then
		width = width + 100
	end
	if #self.outputs > 0 then
		width = width + 100
	end

	width = math.max(width, self.size.x + 20)

	-- Cache text and connector positions, needs to happen whenever the node moves.
	self.text_cache = {}
	for k, v in ipairs(self.inputs) do
		i = i + 1
		local pos = cpml.vec2(self.position.x, self.position.y + spacing * i + offset)
		table.insert(self.text_cache, { v.type, v.label, pos.x, pos.y, input = true, socket = k })
		self.input_position[k] = pos
	end

	local i2 = 1
	for k, v in ipairs(self.outputs) do
		i2 = i2 + 1
		local pos = cpml.vec2(self.position.x + width, self.position.y + spacing * i2 + offset)
		table.insert(self.text_cache, { v.type, v.label, pos.x, pos.y, output = true, socket = k })
		self.output_position[k] = pos
	end
	local height = spacing * (math.max(i, i2) + 1) + 5
	self.display_start = 40

	-- add an extra line for padding
	if self.size.y > 0 and not self.hide_label then
		height = height + 5
	elseif self.hide_label then
		height = math.max(height, self.size.y + 45)
	end

	self.width  = width
	self.height = height + (self.hide_label and 5 or self.size.y)
end

local function type_to_color(k)
	local t = {
		color   = { 255, 255,  50, 255 },
		number  = {   0,  75, 255, 255 },
		boolean = {   0, 255,  75, 255 },
		vector  = { 255,  47,   0, 255 },
		matrix  = { 255,   0  , 0, 255 }
	}
	return t[k] or { 0, 0, 0, 255 }
end

local function type_to_draw(k)
	return ({
		number = function(self, value, x, y, w, h)
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.rectangle("fill", x, y, w, h)
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.printf(value, x + 3, y, w - 6, "left")
		end,
		color = function(self, value, x, y, w, h)
			love.graphics.setColor(value)
			love.graphics.rectangle("fill", x, y, w, h)
		end,
		boolean = function(self, value, x, y, w, h)
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.rectangle("fill", x, y, w, h)
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.printf(tostring(value), x + 3, y, w - 6, "left")
		end,
		vector = function(self, value, x, y, w, h)
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.rectangle("fill", x, y, w, h)
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.printf(tostring(value), x + 3, y, w - 6, "left")
		end,
		matrix = function(self, value, x, y, w, h)
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.rectangle("fill", x, y, w, h)
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.printf(tostring(value), x + 3, y, w - 6, "left")
		end
	})[k] or false
end

local point_offset = cpml.vec2(0, 8)
local point_radius = 5

function noodle:draw()
	local ml = require "material-love"

	-- background
	-- sRGB makes these too wimpy...
	ml.shadow:draw(self.position.x, self.position.y, self.width, self.height, 2)
	ml.shadow:draw(self.position.x, self.position.y, self.width, self.height, 2)
	-- if self.hit then
		-- love.graphics.setColor(210, 210, 255, 255)
		-- love.graphics.setColor(170, 170, 255, 255)
	-- else
	love.graphics.setColor(187, 187, 187, 255)
	-- end
	love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height)
	love.graphics.setColor(0, 0, 0, 80)
	love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, 30)

	if self.selected then
		love.graphics.setColor(50, 255, 50, 255)
		love.graphics.rectangle("line", self.position.x, self.position.y, self.width, self.height)
	end


	-- heading
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print(self.name, self.position.x + 10, self.position.y + 7)

	love.graphics.setPointSize(point_radius*2)
	for i, v in ipairs(self.text_cache) do
		-- Connection points
		local c = type_to_color(v[1])
		local darken = 0.5
		local dark = { c[1] * darken, c[2] * darken, c[3] * darken, c[4] }
		local light = { c[1] * (1+darken), c[2] * (1+darken), c[3] * (1+darken), c[4] }
		love.graphics.setColor((self.hit_connector and self.hit_connector.socket) == i and light or c)
		love.graphics.point(v[3] + point_offset.x, v[4] + point_offset.y)
		love.graphics.setColor(dark)
		love.graphics.circle("line", v[3] + point_offset.x, v[4] + point_offset.y, point_radius, 32)

		-- Labels
		if v.output then
			if not self.hide_label then
				love.graphics.setColor(0, 0, 0, 255)
				love.graphics.printf(v[2], v[3] - 110, v[4], 100, "right")
			end
		else
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.printf(v[2], v[3] + 10, v[4], 100, "left")
			local drawfn = type_to_draw(v[1])
			if drawfn and not self.display and not self.sources[v.socket] then
				local value = self.values[v.socket]
				local w, h = 50, 15
				drawfn(self, value, v[3] + 80, v[4], w, h)
				love.graphics.setColor(0, 0, 0, 255)
				love.graphics.rectangle("line",  v[3] + 80, v[4], w, h)
			end
		end
	end

	if self.display then
		love.graphics.push("all")
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.translate(self.position.x + 10, self.position.y + self.display_start)
		-- love.graphics.setScissor(self.position.x + 10, self.position.y + self.display_start, self.size.x, self.size.y)
		self:display()
		-- love.graphics.setScissor()
		love.graphics.pop()
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle("line", self.position.x + 10, self.position.y + self.display_start, self.size.x, self.size.y)
		love.graphics.setColor(255, 255, 255, 255)
	end
end

function noodle:check_hit(x, y, offset)
	offset = offset or cpml.vec2(0, 0)
	local test = cpml.intersect.point_AABB
	local pos  = cpml.vec3(x - offset.x, y - offset.y)

	-- highlight if we're dead on
	self.hit = test(pos, {
		position = cpml.vec3(self.position.x, self.position.y, 0),
		volume   = cpml.vec3(self.width, self.height, 0)
	})
	self.hit_connector = false

	-- test again with padding, node connectors are slightly outside the box...
	if test(pos, {
		position = cpml.vec3(self.position.x - 10, self.position.y - 10),
		volume   = cpml.vec3(self.width + 20, self.height + 20)
	}) then
		-- check all the connectors for hits, now
		for i, v in ipairs(self.text_cache) do
			local connector = cpml.vec2(v[3], v[4]) + point_offset
			local point_radius = point_radius + 5 -- default radius is hard to hit
			local hit = test(pos, {
				position = cpml.vec3(connector.x - point_radius, connector.y - point_radius),
				volume   = cpml.vec3(point_radius * 2, point_radius * 2)
			})
			if hit then
				self.hit_connector = {
					node     = self,
					socket   = v.socket,
					color    = type_to_color(v[1]),
					position = cpml.vec2(v[3], v[4]),
					input    = v.input,
					output   = v.output
				}
				break
			end
		end
	end
end

local function draw_noodle(v1, v2, color)
	local first = v1 + point_offset
	local last = v2 + point_offset

	-- 1-2 is mega-curvy, 0 is straight, >2 is a gentle curve.
	-- How the hell am I even supposed to name that?
	local curviness = 4
	local bezier
	if curviness == 0 then
		bezier = love.math.newBezierCurve(first.x, first.y, last.x, last.y)
	else
		bezier = love.math.newBezierCurve(
			first.x, first.y,
			first.x + (last.x - first.x) / curviness, first.y,
			last.x - (last.x - first.x) / curviness, last.y,
			last.x, last.y
		)
	end

	if color then
		love.graphics.setColor(color)
	end

	-- Arrows
	local arrow_width, arrow_length = 5, 10
	love.graphics.push()
	love.graphics.translate(last.x, last.y)

	local len = first:dist(last)
	local pos = cpml.utils.clamp((len - arrow_length * 1.5) / len, 0, 1)
	love.graphics.rotate(last:angle_to(cpml.vec2(bezier:evaluate(pos)))-math.pi/2)

	love.graphics.polygon("fill", -arrow_width, -arrow_length, arrow_width, -arrow_length, 0, 0)
	love.graphics.pop()

	-- No need for subdivisions if it's straight.
	love.graphics.line(bezier:render(curviness == 0 and 1 or 4))
end

-- Given a starting node, draw noodles recursively through to the end of the chain.
local function noodleize(node, drawn)
	for k, con in pairs(node.connections) do
		for i, to in ipairs(con) do
			love.graphics.setColor(type_to_color(node.outputs[k].type))

			local first = cpml.vec2(node.output_position[k].x, node.output_position[k].y)
			local last = cpml.vec2(to.node.input_position[to.socket].x, to.node.input_position[to.socket].y)

			draw_noodle(first, last)

			-- Make sure we only draw the noodles once.
			if not lume.find(drawn, to.node) then
				table.insert(drawn, to.node)
				noodleize(to.node, drawn)
			end
		end
	end
end

local function draw_nodes(node_list)
	assert(type(node_list) == "table" or is_node(node_list), "Expected node or node list")
	if is_node(node_list) then
		node_list = { node_list }
	end

	local c = {love.graphics.getColor()}
	local leaders = {}
	for i, v in ipairs(node_list) do
		if not v.leader then
			table.insert(leaders, v)
		end
		v:draw()
	end
	local drawn = {}
	for i, v in ipairs(leaders) do
		noodleize(v, drawn)
	end
	love.graphics.setColor(c)
end

local function evaluate_list(node_list)
	local endpoints = {}
	for i, v in ipairs(node_list) do
		v.needs_eval = false
		if lume.count(v.connections) == 0 then
			table.insert(endpoints, v)
		end
	end

	-- because thou must
	local function go_deeper(node, path)
		for k, v in pairs(node.sources) do
			-- print(v.node.name, v.node.values)
			table.insert(path, { v.node, v.socket, v.output })
			go_deeper(v.node, path)
		end
	end

	for i, node in ipairs(endpoints) do
		print(string.format("Path %d (%s)", i, node.name))
		local path = {}
		go_deeper(node, path)
		for i, v in lume.ripairs(path) do
			local eval = v[1]
			print("Evaluating node " .. eval.name)
			local data = { eval:evaluate() }
			for socket, value in ipairs(data) do
				if eval.connections[socket] then
					for _, to in ipairs(eval.connections[socket]) do
						to.node.values[to.socket] = value
					end
				end
			end
		end
		print("Final Values:")
		for i, v in ipairs(node.values) do
			print(i, v)
		end
	end
end

return setmetatable(
	{
		new              = new,
		draw_nodes       = draw_nodes,
		draw_noodle      = draw_noodle,
		draw_connections = noodleize,
		evaluate_list    = evaluate_list,
		is_node          = is_node
	},
	{ __call = function(_, ...) return new(...) end }
)
