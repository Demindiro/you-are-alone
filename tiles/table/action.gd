extends GWJ30_TileAction_Inventory
class_name GWJ30_TileAction_Table

func _init() -> void:
	name = "Table"
	items = [null]

func do(_player: GWJ30_Player) -> GWJ30_TileActionResult:
	return GWJ30_TileActionResult_Inventory.new(items)
