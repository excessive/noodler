local node    = require "node"
local json    = require "dkjson"
local cpml    = require "cpml"
local items   = {}
local noodler = {}

function noodler.encode(nodes)
	local serial = {
		nodes       = {},
		positions   = {},
		values      = {},
		connections = {}
	}

	-- Serialize nodes
	for output, n in ipairs(nodes) do
		local sn = {}
		local sp = {}
		local sv = {}

		-- node, mode
		print(n.file)
		table.insert(sn, n.file)
		--table.insert(sn, n.mode) -- this needs to be added!

		-- x, y
		table.insert(sp, n.position.x)
		table.insert(sp, n.position.y)

		-- values 1, 2, ..., n
		for _, v in ipairs(n.values) do
			table.insert(sv, v)
		end

		-- connections
		for _, socket in ipairs(n.connections) do
			local sc = {}

			-- Get sockets with connections
			for output_socket, connection in pairs(socket) do
				local input
				local input_socket = connection.socket

				-- Get index of connected node
				for i in ipairs(nodes) do
					if nodes[i] == connection.node then
						input = i
						break
					end
				end

				-- output, input, output_socket, input_socket
				table.insert(sc, output)
				table.insert(sc, input)
				table.insert(sc, output_socket)
				table.insert(sc, input_socket)

				print(output, input, output_socket, input_socket)
			end

			table.insert(serial.connections, sc)
		end

		table.insert(serial.nodes,     sn)
		table.insert(serial.positions, sp)
		table.insert(serial.values,    sv)
	end

	return json.encode(serial)
end

function noodler.decode(encoded)
	print(encoded)
	local decoded = json.decode(encoded)
	local nodes   = {}

	-- Create nodes
	for k in ipairs(decoded.nodes) do
		-- Get the node type, position, and values
		local nod = decoded.nodes[k]
		local pos = decoded.positions[k]
		local val = decoded.values[k]

		-- Create default node of given type
		local item = items[nod[1]].new()
		item.x     = pos[1]
		item.y     = pos[2]
		local n    = node(item)

		-- Assign node values
		for i, v in ipairs(val) do
			n.values[i] = v
		end

		-- Insert node into list
		table.insert(nodes, n)
	end

	-- Create connections
	for k in ipairs(decoded.connections) do
		-- Get connection data
		local con           = decoded.connections[k]
		local output        = nodes[con[1]]
		local input         = nodes[con[2]]
		local output_socket = con[3]
		local input_socket  = con[4]

		-- Connect nodes
		output:connect(input, output_socket, input_socket)
	end

	return nodes
end

-- load nodes
for i, file in ipairs(love.filesystem.getDirectoryItems("src/nodes")) do
	xpcall(function()
		local item = love.filesystem.load("src/nodes/" .. file)(string.sub(file, 1, -5))
		items[string.sub(file, 1, -5)] = item
	end, print)
end

return noodler
