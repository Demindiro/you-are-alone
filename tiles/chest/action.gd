extends GWJ30_TileAction_Inventory
class_name GWJ30_TileAction_Chest

func _init() -> void:
	name = "Chest"
	items = ["Foo", "Bar", "Qux"]

func do(player: GWJ30_Player) -> GWJ30_TileActionResult:
	return GWJ30_TileActionResult_Inventory.new(items)
