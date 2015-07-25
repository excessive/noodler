The serialization format should be the following encoded as JSON.

Other representations may be added in the future.

```lua
-- <node_id> is implied by the table index value
-- the nodes and values tables are always synced so they share the same indices
-- <socket_id> is implied by the sub-table index value within values

return {
	nodes = {
		-- node, mode
		{ "color-mix" },
		{ "input-rgba" },
		{ "input-rgba" },
		{ "math-operations", "add" },
		{ "input-number" },
		{ "input-number" }
	},

	values = {
		-- socket_1.value, socket_2.value, ..., socket_n.value
		{ 1, { 255, 255, 255, 255 }, { 255, 255, 255, 255 } },
		{ { 255, 0, 0, 255 } },
		{ { 0, 0, 255, 255 } },
		{ 0, 0 },
		{ 1 },
		{ 1 }
	},

	connections = {
		-- out.node_id, in.node_id, out.node_id.socket_id, in.node_id.socket_id
		{ 2, 1, 1, 2 },
		{ 3, 1, 1, 3 },
		{ 5, 4, 1, 1 },
		{ 6, 4, 1, 2 }
	}
}
```
