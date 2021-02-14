tool
extends TileMap
class_name GWJ30_Room


const CELL_SIZE := 16


func _ready() -> void:
	cell_size = Vector2(CELL_SIZE, CELL_SIZE)
	tile_set = preload("res://tiles/tileset.tres")
	scale = Vector2.ONE / CELL_SIZE
