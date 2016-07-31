local node = require "node"

return {
	name     = "Note",
	category = "Misc",
	function(tree, position)
		return tree:add(
			node {
				name = "Note"
			},
			position
		)
	end
}
