extends GWJ30_TileActionResult
class_name GWJ30_TileActionResult_Puzzle

signal solved

var owner: WeakRef

func put_item(_item: String) -> bool:
	assert(false, "put_item() must be overriden")
	return false

func get_ui() -> Control:
	assert(false, "get_ui() must be overriden")
	return null

func do(player) -> GWJ30_TileActionResult:
	return owner.get_ref().do(player)
