function love.conf(t)
	t.version = "0.10.0"
	t.window = nil
	t.gammacorrect    = true
	t.modules.audio   = false
	t.modules.sound   = false
	t.modules.physics = false
	io.stdout:setvbuf("no")
end

if love.filesystem.setRequirePath then
	love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. ";libs/?.lua;libs/?/init.lua")
	love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. ";src/?.lua;src/?/init.lua")
end
