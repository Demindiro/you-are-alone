extends GWJ30_TileActionResult
class_name GWJ30_TileActionResult_Puzzle

func put_item(_item: String) -> bool:
	assert(false, "put_item() must be overriden")
	return false

func get_ui() -> Control:
	assert(false, "get_ui() must be overriden")
	return null
