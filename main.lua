love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. ";libs/?.lua;libs/?/init.lua")
love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. ";src/?.lua;src/?/init.lua")

local cpml     = require "cpml"
local node     = require "node"
local serial   = require "serial_nood"
local editgrid = require "editgrid"

local node_list      = {}
local selected       = false
local grabbed        = false
local new_connection = false

local offset, panning = cpml.vec2(0, 0), false
local lf, menu

function love.load(args)
	love.window.setMode(1280, 720, {
		fullscreen = false,
		msaa      = 4,
		srgb      = true,
		resizable = true,
		vsync     = true,
	})
	love.window.setTitle("Noodler")

	-- Depends on the window being created first.
	lf = require "libs.UnekFrames"
	love.graphics.setFont(love.graphics.newFont("assets/NotoSans-Regular.ttf", 12))

	love.graphics.setBackgroundColor { 40, 40, 40 }

	local items = {}
	for i, file in ipairs(love.filesystem.getDirectoryItems("src/nodes")) do
		xpcall(function()
			local item = love.filesystem.load("src/nodes/" .. file)(string.sub(file, 1, -5))
			items[item.category] = items[item.category] or {}
			table.insert(items[item.category], item)
		end, print)
	end

	local panel = assert(lf.Create("panel"))
	function panel:draw()
		for k, v in ipairs(self.children) do
			v:draw()
		end
	end

	panel:SetSize(love.graphics.getDimensions())
	menu = lf.Create("menu", panel)
	menu:SetVisible(false)

	local menus = {}
	for name, category in pairs(items) do
		for _, item in ipairs(category) do
			menus[name] = menus[name] or {}
			table.insert(menus[name], item)
		end
	end
	for name, category in pairs(menus) do
		local sub = lf.Create("menu")
		for _, item in ipairs(category) do
			sub:AddOption(item.name, false, function()
				local pos = cpml.vec2(love.mouse.getPosition())
				grabbed = item.new((pos - offset):unpack())
				selected = grabbed
				love.mouse.setGrabbed(true)
				grabbed.selected = true
				grabbed:update()
				table.insert(node_list, grabbed)
			end)
		end
		menu:AddSubMenu(name, false, sub)
	end

	local w, h = love.graphics.getDimensions()
	offset.x = w / 2
	offset.y = h / 2
end

function love.keypressed(k, s, rep)
	if k == "g" and not rep then
		if grabbed then
			love.mouse.setGrabbed(false)
			grabbed = false
		elseif selected then
			love.mouse.setGrabbed(true)
			grabbed = selected
		end
		return
	end
	if (k == "x" or k == "delete") and selected and not selected.invulnerable and not rep then
		selected:disconnect(nil, true)
		for i, v in ipairs(node_list) do
			if v == selected then
				table.remove(node_list, i)
				break
			end
		end
		selected = false
	end
	if k == "d" and selected and not rep then
		local new = selected:clone()
		new:update()
		selected.selected = false
		selected.hit      = false
		new.selected      = true
		new.hit           = true
		selected = new
		grabbed  = new
		table.insert(node_list, new)
	end

	-- TEST SERIALIZATION
	if k == "q" then
		debug_serial = serial.encode(node_list)
		node_list    = {}
	end

	if k == "e" then
		node_list    = serial.decode(debug_serial)
		debug_serial = nil
	end
	-- END TEST

	if k == "home" then
		local w, h = love.graphics.getDimensions()
		offset.x = w / 2
		offset.y = h / 2
	end

	lf.keypressed(k)
end

function love.keyreleased(k)
	lf.keyreleased(k)
end
--
function love.textinput(t)
	lf.textinput(t)
end

function love.mousepressed(x, y, button)
	if button == 1 then
		if not grabbed and not new_connection then
			selected = false
			for i, v in ipairs(node_list) do
				v:check_hit(x, y, offset)
				if v.hit_connector and v.hit_connector.output then
					new_connection = v.hit_connector
				elseif v.hit and not v.hit_connector then
					grabbed = v
					love.mouse.setGrabbed(true)
				end
				v.selected = v.hit
				if v.selected then
					selected = v
				end
			end
		else
			love.mouse.setGrabbed(false)
			grabbed = false
			new_connection = false
		end
	end
	if button == 2 then
		menu:SetPos(x, y)
		menu:SetVisible(true)
	end
	if button == 3 then
		panning = true
	end
	if button <= 5 then
		lf.mousepressed(x, y, button)
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then
		if grabbed then
			grabbed = false
			love.mouse.setGrabbed(false)
		end
		if new_connection then
			for i, v in ipairs(node_list) do
				v:check_hit(x, y, offset)
				if v.hit_connector and v.hit_connector.input then
					print("dropped on a connector!")
					print(new_connection.socket, v.hit_connector.socket)
					new_connection.node:connect(v.hit_connector.node, new_connection.socket, v.hit_connector.socket)
				end
			end
			new_connection = false
		end
	end
	if button == 2 then
		for i, v in ipairs(node_list) do
			v:check_hit(x, y, offset)
			if v.hit_connector and v.hit_connector.input then
				v:disconnect(v.hit_connector.socket)
				break
			end
		end
	end
	if button == 3 then
		panning = false
	end
	if button <= 5 then
		lf.mousereleased(x, y, button)
	end
end

function love.update(dt)
	for i, v in ipairs(node_list) do
		if v.needs_eval then
			print("Nodes updated, evaluating...")
			node.evaluate_list(node_list)
			break
		end
	end
	lf.update(dt)
end

function love.mousemoved(x, y, dx, dy)
	for i, v in ipairs(node_list) do
		v:check_hit(x, y, offset)
	end
	if grabbed then
		grabbed.position = grabbed.position + cpml.vec2(dx, dy)
		grabbed:update()
	end
	if panning then
		offset.x = offset.x + dx
		offset.y = offset.y + dy
	end
end

function love.draw()
	local w, h = love.graphics.getDimensions()

	-- background grid
	editgrid.draw({
		x  = -offset.x + w / 2,
		y  = -offset.y + h / 2,
		sw = w,
		sh = h
	}, {
		size = 50,
		subdivisions = 5,
		color = { 20, 20, 20 },
		xColor = { 255, 0, 0 },
		yColor = { 0, 255, 0 },
		fadeFactor = 1.5,
		textFadeFactor = 0.75,
	})

	love.graphics.push()
	love.graphics.translate(offset:unpack())

	node.draw_nodes(node_list)

	if new_connection then
		node.draw_noodle(new_connection.position, cpml.vec2(love.mouse.getPosition()) - offset, new_connection.color)
	end

	love.graphics.pop()

	lf.draw()
end

-- Exactly the same as normal, but only renders when an event was handled.
function love.run()
	if love.math then
		love.math.setRandomSeed(os.time())
		for i=1,3 do love.math.random() end
	end
	if love.event then
		love.event.pump()
	end
	if love.load then love.load(arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	local needs_update = 0
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						if love.audio then
							love.audio.stop()
						end
						return
					end
				end
				love.handlers[name](a,b,c,d,e,f)
				needs_update = 3
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.window and love.graphics and love.window.isCreated() and needs_update > 0 then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
			needs_update = needs_update - 1
		end

		-- Run a fast GC cycle so that it happens at predictable times.
		collectgarbage("step")

		if love.timer then love.timer.sleep(0.01) end
	end
end
