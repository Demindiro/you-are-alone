extends GWJ30_TileAction
class_name GWJ30_TileAction_Floor

func _init() -> void:
	name = "Move"

func do(player: GWJ30_Player) -> GWJ30_TileActionResult:
	player.position = position
	return GWJ30_TileActionResult_None.new()
