extends GWJ30_TileAction_Inventory
class_name GWJ30_TileAction_Puzzle

func get_necessary_items() -> PoolStringArray:
	assert(false, "get_necessary_items() must be overriden")
	return PoolStringArray()

func is_solved() -> bool:
	assert(false, "is_solved() must be overriden")
	return false
