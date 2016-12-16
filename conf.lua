-- Game flags (beyond love's own)
-- TODO: Read a preferences file for conf stuff?
_G.FLAGS = {
	game_version  = "0.0.0",
	debug_mode    = false,
	show_perfhud  = false,
	show_overscan = false,
	headless      = false
}

local use = {
	highdpi_hack       = true,
	hot_reloader       = true,
	fps_in_title       = true,
	handle_screenshots = true,
	event_poll         = true,
	love_draw          = true,
	console            = false,
	love3d             = false,
	console_font       = {
		path = "assets/unifont-7.0.06.ttf",
		size = 16
	},
	log_header = "shit we broke it"
}

if not _G.FLAGS.headless then
	require "love.system"
	require "love.window"
end

-- Add folders to require search path
love.filesystem.setRequirePath(
	love.filesystem.getRequirePath()
	.. ";libs/?.lua;libs/?/init.lua"
	.. ";src/?.lua;src/?/init.lua"
)

-- Specify window flags here because we use some of them for the error screen.
local flags = {
	title          = "Noodler",
	width          = 1280,
	height         = 720,
	fullscreen     = false,
	fullscreentype = "desktop",
	msaa           = 4,
	vsync          = true,
	resizable      = false,
	highdpi        = true
}

if use.highdpi_hack and love.system.getOS() == "Linux" and not _G.FLAGS.headless then
	flags.highdpi = false

	local lume      = require "lume"
	local f         = io.popen("gsettings get org.gnome.desktop.interface scaling-factor")
	local _scale    = lume.split(f:read() or "it's 1", " ")
	local dpi_scale = _scale[2] and tonumber(_scale[2]) or 1.0

	if dpi_scale >= 0.5 then
		flags.width  = flags.width  * dpi_scale
		flags.height = flags.height * dpi_scale

		love.window.toPixels = function(v)
			return v * dpi_scale
		end

		love.window.getPixelScale = function()
			return dpi_scale
		end
	end
end

function love.conf(t)
	t.version = "0.10.2"

	for k, v in pairs(flags) do
		t.window[k] = v
	end

	t.gammacorrect          = true -- Always use gamma correction.
	t.accelerometerjoystick = false -- Disable joystick accel on mobile
	t.modules.physics       = false
	t.modules.audio         = not _G.FLAGS.headless

	io.stdout:setvbuf("no") -- Don't delay prints.
end

--------------------------------------------------
-- /!\ Here be dragons. Thou art forewarned /!\ --
--------------------------------------------------

-- Helpers for hot reloading the whole game.
-- I apologize for the global, but thou must.
local fire = {}
package.loaded.fire = fire
local pkg_cache = {}
local callbacks = {}
local world_saved = false

-- Save packages from startup so we can reset to this state at a later time
function fire.save_the_world()
	world_saved = true
	pkg_cache = {}
	callbacks = {}
	for k, v in pairs(package.loaded) do
		pkg_cache[k] = v
	end
	for k, v in pairs(love) do
		callbacks[k] = v
	end
	pkg_cache.main = nil
end

-- Restore saved cache so Lua has to reload everything.
function fire.reset_the_world()
	if not world_saved then
		print "[Fire] No state saved to reset the world to."
		return
	end
	-- unload
	if love.quit then
		love.quit()
	end
	for k in pairs(package.loaded) do
		package.loaded[k] = pkg_cache[k]
	end
	for _, k in ipairs {
		'focus', 'keypressed', 'keyreleased', 'mousefocus', 'mousemoved',
		'mousepressed', 'mousereleased', 'wheelmoved', 'textedited', 'textinput',
		'resize', 'visible', 'gamepadaxis', 'gamepadpressed', 'gamepadreleased',
		'joystickadded', 'joystickaxis', 'joystickhat', 'joystickpressed',
		'lowmemory', 'joystickreleased', 'joystickremoved', 'filedropped',
		'directorydropped', 'update', 'quit', 'load', 'draw'
	} do
		love[k] = nil
	end
	for k, v in pairs(callbacks) do
		love[k] = v
	end

	if love.audio then
		love.audio.stop()
		love.audio.setVolume(1.0)
	end

	if love.mouse then
		love.mouse.setGrabbed(false)
		love.mouse.setVisible(true)
		love.mouse.setRelativeMode(false)
	end

	-- Clean out everything, just to be sure.
	collectgarbage("collect")
	-- Note: you have to collect TWICE to make sure everything is GC'd.
	collectgarbage("collect")

	require "main"

	print "Reloading game!"

	return love.run()
end


-- A few convenience functions.
function fire.open_save()
	love.system.openURL("file://" .. love.filesystem.getSaveDirectory())
end

function fire.toggle_fullscreen()
	love.window.setFullscreen(not love.window.getFullscreen())
end

function fire.take_screenshot()
	love.filesystem.createDirectory("Screenshots")

	local ss   = love.graphics.newScreenshot()
	local path = string.format("%s/%s.png",
		"Screenshots",
		os.date("%Y-%m-%d_%H-%M-%S", os.time())
	)
	local f = love.filesystem.newFile(path)
	ss:encode("png", path)
end

local fix_love10_colors = function(t) return t end
if select(2, love.getVersion()) <= 10 then
	fix_love10_colors = function(t)
		return { t[1] * 255, t[2] * 255, t[3] * 255, t[4] * 255 }
	end
end

local perfhud = {
	color = {
		bg = fix_love10_colors { 0.0, 0.0, 0.0, 0.75 },
		good = fix_love10_colors { 0.5, 1.0, 0.5, 0.75 },
		bad  = fix_love10_colors { 1.0, 0.0, 0.0, 1.0 }
	},
	limit = 1/20,
	target = 1/60 + 1/400, -- tolerance
	data = {},
	pos = {
		x = love.window.toPixels(10),
		y = love.window.toPixels(10)
	},
	max_samples = 120,
	bar_width = love.window.toPixels(5),
	height    = love.window.toPixels(40),
}
perfhud.spacing   = math.floor(perfhud.bar_width * 1.2)
perfhud.width     = perfhud.spacing * perfhud.max_samples - (perfhud.spacing - perfhud.bar_width)

local l3d_loaded     = false
local console_loaded = false

local colors = {
	white = { bg = { 255, 255, 255, 200 }, fg = { 0, 0, 0, 255 }  },
	black = { bg = { 0, 0, 0, 200 },   fg = { 255, 255, 255, 255 }  },
	green = { bg = { 0, 150, 0, 200 }, fg = { 255, 255, 255, 255 }  },
	red   = { bg = { 150, 0, 0, 200 }, fg = { 255, 255, 255, 255 }  },
	blue  = { bg = { 0, 0, 150, 200 }, fg = { 255, 255, 255, 255 }  }
}
colors.default = colors.black

local prints = {}
local font = false

function fire.get_font()
	return font
end

function fire.set_font(f)
	font = f
end

function fire.clear_prints()
	while #prints > 0 do
		table.remove(prints)
	end
end

function fire.print(str, x, y, color)
	color = colors[color] or colors.default
	assert(x, "fire.print requires an x position")
	assert(y, "fire.print requires a y position")
	table.insert(prints, {
		x = x,
		y = y,
		color = color,
		str = tostring(str)
	})
end

local binds = {}

function fire.clear_binds(key)
	for k, v in pairs(binds) do
		if (key ~= nil and key == k) or (key == nil) then
			while #v > 0 do
				table.remove(v)
			end
		end
	end
end

function fire.bind(key, fn)
	binds[key] = binds[key] or {}

	-- only allow binding a function once per key
	for _, _fn in ipairs(binds[key]) do
		if _fn == fn then
			return
		end
	end

	table.insert(binds[key], fn)
end

function fire.trigger(key, scancode, is_repeat)
	if not binds[key] or is_repeat then
		return false
	end

	for _, fn in ipairs(binds[key]) do
		local r = fn(key)
		if r then
			return true
		end
	end

	return false
end

function love.run()
	-- Add gamepads
	if love.joystick then
		if love.filesystem.isFile("assets/gamecontrollerdb.txt") then
			love.joystick.loadGamepadMappings("assets/gamecontrollerdb.txt")
		end
	end

	local fire = require "fire"
	local reset = false

	if use.love3d and not l3d_loaded then
		l3d_loaded = true
		require "love3d".import(true, false)
	end

	if use.console and not console_loaded then
		console_loaded = true
		_G.console = require "console"
		local console = _G.console
		local params = use.console_font and use.console_font or { path = false, size = 14 }
		local have_font = params.path and love.filesystem.isFile(params.path) or false
		local font
		if have_font then
			font = love.graphics.newFont(params.path, math.floor(love.window.toPixels(params.size)))
		else
			font = love.graphics.newFont(math.floor(love.window.toPixels(params.size)))
		end
		console.load(font)
		console.update(0)
	end

	local fp = "assets/fonts/Inconsolata-Regular.ttf"
	if love.filesystem.isFile(fp) then
		fire.set_font(love.graphics.newFont(fp, math.floor(love.window.toPixels(16))))
	else
		fire.set_font(love.graphics.newFont(math.floor(love.window.toPixels(16))))
	end

	if console then
		if use.hot_reloader then
			console.clearCommand("restart")
			console.defineCommand(
				"restart",
				"Reload game files and restart the game.",
				function()
					reset = true
				end
			)
		end
		console.clearCommand("perfhud")
		console.defineCommand(
			"perfhud",
			"Toggle framerate overlay.",
			function()
				_G.FLAGS.show_perfhud = not _G.FLAGS.show_perfhud
			end
		)
	end

	if use.hot_reloader then
		fire.save_the_world()
	end

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
	local last_update = -0.5 -- update immediately!

	-- Main loop time.
	while true do
		fire.bind("f8", function()
			_G.FLAGS.debug_mode = not _G.FLAGS.debug_mode
		end)
		if _G.FLAGS.debug_mode then
			fire.bind("f9", function()
				_G.FLAGS.show_perfhud = not _G.FLAGS.show_perfhud
			end)
			fire.bind("f10", function()
				_G.FLAGS.show_overscan = not _G.FLAGS.show_overscan
			end)
		end
		-- Process events.
		if love.event then
			love.event.pump()
			if use.event_poll then
				for name, a,b,c,d,e,f in love.event.poll() do
					if name == "keypressed" and a == "f5" then
						reset = true
					end
					if use.handle_screenshots then
						if name == "keypressed" and a == "f11" then
							fire.open_save()
						end
						if name == "keypressed" and a == "f12" then
							fire.take_screenshot()
						end
					end
					if name == "keypressed" and a == "return" then
						if (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")) then
							fire.toggle_fullscreen()
						end
					end
					if name == "keypressed" and a == "escape" and
						(love.keyboard.isDown "lshift" or love.keyboard.isDown "rshift")
					then
						love.event.quit()
					end
					if name == "quit" then
						if not love.quit or not love.quit() then
							return
						end
					end
					if not console
						or not console[name]
						or (not (type(console[name]) == "function" and console[name](a,b,c,d,e,f)))
					then
						if name ~= "keypressed" or (name == "keypressed" and not fire.trigger(a,b,c,d,e,f)) then
							love.handlers[name](a,b,c,d,e,f)
						end
					end
				end
			end
			fire.clear_binds()
		end

		if _G.FLAGS.debug_mode then
			fire.print("DEBUG MODE", 0, 0, "red")
		end

		if use.hot_reloader and reset then
			break
		end

		-- Update dt, as we'll be passing it to update
		local skip_time = false
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
			if love.keyboard.isDown "tab" then
				dt = dt * 4
			else
				-- Cap dt to 30hz - this results in slowmo, but that's less
				-- bad than the things that enormous deltas can cause.
				if dt > 1/30 then
					-- Record full delta if we're skipping frames, so that
					-- it can still be handled.
					skip_time = dt
				end
				dt = math.min(dt, 1/30)
			end
		end

		-- Call update and draw
		if love.graphics and love.graphics.isActive() then
			-- Discarding here causes issues with NVidia 352.41 on Linux
			-- love.graphics.discard()
			love.graphics.clear(love.graphics.getBackgroundColor())

			-- make sure the console is always updated
			if console then console.update(dt) end
			 -- will pass 0 if love.timer is disabled
			if love.update then love.update(dt, skip_time) end

			if use.love_draw and love.draw then love.draw() end

			if console then console.draw() end

			table.insert(perfhud.data, skip_time or dt)
			while #perfhud.data > perfhud.max_samples do
				table.remove(perfhud.data, 1)
			end
			if _G.FLAGS.show_perfhud then
				love.graphics.setColor(perfhud.color.bg)
				love.graphics.rectangle("fill", perfhud.pos.x, perfhud.pos.y, perfhud.width, perfhud.height)

				for i = #perfhud.data, 1, -1 do
					local x = (i-1) * perfhud.spacing
					local bar_height = perfhud.height * (perfhud.data[i] / perfhud.limit)
					if perfhud.data[i] <= perfhud.target then
						love.graphics.setColor(perfhud.color.good)
					else
						love.graphics.setColor(perfhud.color.bad)
					end
					love.graphics.rectangle("fill",
						perfhud.pos.x + x,
						perfhud.pos.y + perfhud.height - bar_height,
						perfhud.bar_width, bar_height
					)
				end
			end

			love.graphics.origin()
			if _G.FLAGS.debug_mode then
				local f = fire.get_font()
				local w = f:getWidth(" ")
				local h = f:getHeight()
				for _, p in ipairs(prints) do
					local x = p.x * w
					local y = p.y * h
					love.graphics.setFont(f)
					love.graphics.setColor(p.color.bg)
					love.graphics.rectangle("fill", x, y, f:getWidth(p.str), h)
					love.graphics.setColor(p.color.fg)
					love.graphics.print(p.str, x, y)
				end
				love.graphics.setColor(255, 255, 255, 255)
			end

			love.graphics.present()

			-- clear debug prints for this frame
			fire.clear_prints()

			-- Run a fast GC cycle so that it happens at predictable times.
			-- This prevents GC work from building up and causing hitches.
			collectgarbage("step")
			-- collectgarbage("step")

			-- surrender just a little bit of CPU time to the OS
			if love.timer then love.timer.sleep(0.001) end

			local now = love.timer.getTime()
			if use.fps_in_title and now - last_update >= 0.25 then
				last_update = now
				love.window.setTitle(string.format(
					"%s - %s (%5.4fms/f %2.2ffps)",
					flags.title,
					_G.FLAGS.game_version,
					love.timer.getAverageDelta() * 1000,
					love.timer.getFPS()
				))
			end
		end
	end

	if use.hot_reloader and reset then
		return fire.reset_the_world()
	end
end

local debug, print = debug, print

local function error_printer(msg, layer)
	local filename = "crash.log"
	local file     = ""
	local time     = os.date("%Y-%m-%d %H:%M:%S", os.time())
	local err      = debug.traceback(
		"Error: " .. tostring(msg), 1+(layer or 1)
	):gsub("\n[^\n]+$", "")

	if love.filesystem.isFile(filename) then
		file = love.filesystem.read(filename)
	end

	if file == "" then
		file = use.log_header .. "\n\n"
	else
		file = file .. "\n\n"
	end

	file = file .. string.format([[
=========================
== %s ==
=========================

%s]], time, err)

	love.filesystem.write(filename, file)
	print(err)
end

function love.errhand(msg)
	function rgba(color)
		local a = math.floor((color / 16777216) % 256)
		local r = math.floor((color /    65536) % 256)
		local g = math.floor((color /      256) % 256)
		local b = math.floor((color) % 256)
		return r, g, b, a
	end

	msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, flags.width, flags.height)
		if not success or not status then
			return
		end
	end

	love.window.setTitle(flags.title)

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
	local font_path = "assets/fonts/NotoSans-Regular.ttf"
	local head, font
	if love.filesystem.isFile(font_path) then
		head = love.graphics.newFont(font_path, math.floor(love.window.toPixels(22)))
		font = love.graphics.newFont(font_path, math.floor(love.window.toPixels(14)))
	else
		print "Error screen font missing, using default instead."
		head = love.graphics.newFont(math.floor(love.window.toPixels(22)))
		font = love.graphics.newFont(math.floor(love.window.toPixels(14)))
	end

	love.graphics.setBackgroundColor(rgba(0xFF1E1E2C))
	love.graphics.setColor(255, 255, 255, 255)

	-- Don't show conf.lua in the traceback.
	local trace = debug.traceback("", 2)

	love.graphics.clear(love.graphics.getBackgroundColor())
	love.graphics.origin()

	local err = {}

	table.insert(err, msg.."\n")

	for l in string.gmatch(trace, "(.-)\n") do
		if not string.match(l, "boot.lua") then
			l = string.gsub(l, "stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local c = string.format("Please locate the crash.log file at: %s\n\nI can try to open the folder for you if you press F11!", love.filesystem.getSaveDirectory())
	local h = "Oh no, it's broken!"
	local p = table.concat(err, "\n")

	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

	local function draw()
		local pos = love.window.toPixels(70)
		love.graphics.clear(love.graphics.getBackgroundColor())
		love.graphics.setColor(rgba(0xFFF0A3A3))
		love.graphics.setFont(head)
		love.graphics.printf(h, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.setFont(font)
		love.graphics.setColor(rgba(0xFFD2D5D0))
		love.graphics.printf(c, pos, pos + love.window.toPixels(40), love.graphics.getWidth() - pos)
		love.graphics.setColor(rgba(0xFFA2A5A0))
		love.graphics.printf(p, pos, pos + love.window.toPixels(120), love.graphics.getWidth() - pos)
		love.graphics.present()
	end

	local reset = false

	while true do
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			elseif e == "keypressed" and a == "f11" then
				fire.open_save()
			elseif e == "keypressed" and a == "f12" then
				fire.take_screenshot()
			elseif e == "keypressed" and a == "f5" then
				reset = true
				break
			elseif e == "keypressed" and a == "escape" and (love.window.getFullscreen()) then
				return
			elseif e == "keypressed" and a == "escape" then --or e == "mousereleased" then
				return
			end
		end

		if use.hot_reloader and reset then
			break
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end

	if use.hot_reloader and reset then
		return xpcall(fire.reset_the_world, love.errhand)
	end
end
