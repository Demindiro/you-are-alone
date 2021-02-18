class_name GWJ30_TileAction

var name: String
var position: Vector2
var map#: GWJ30_Map

func do(_player: GWJ30_Player) -> GWJ30_TileActionResult:
	assert(false, "do() must be overriden")
	return null
