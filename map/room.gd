tool
extends TileMap
class_name GWJ30_Room


const CELL_SIZE := 16
const FLOOR_TILE_ID := 1


func _ready() -> void:
	cell_size = Vector2(CELL_SIZE, CELL_SIZE)
	tile_set = preload("res://tiles/tileset.tres")
	scale = Vector2.ONE / CELL_SIZE

	if Engine.editor_hint:
		print("Generating room resource")
		var entrances := PoolVector2Array()
		for pos in get_used_cells():
			if get_cellv(pos) == FLOOR_TILE_ID:
				if get_cellv(pos + Vector2.LEFT) == TileMap.INVALID_CELL or \
					get_cellv(pos + Vector2.RIGHT) == TileMap.INVALID_CELL or \
					get_cellv(pos + Vector2.UP) == TileMap.INVALID_CELL or \
					get_cellv(pos + Vector2.DOWN) == TileMap.INVALID_CELL:
					entrances.push_back(pos)
		print("Saving room resource")
		var res := GWJ30_RoomResource.new()
		res.resource_name = name
		res.resource_path = filename.get_basename() + ".tres"
		res.scene_path = filename
		res.entrances = entrances
		res.size = get_used_rect()
		ResourceSaver.save(res.resource_path, res)
