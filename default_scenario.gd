extends Node

export var player_path := NodePath()
export var enemy_path := NodePath()
onready var player: GWJ30_Player = get_node(player_path)
onready var enemy: GWJ30_Enemy = get_node(enemy_path)
var map: GWJ30_Map

func _ready() -> void:
	assert(map != null, "Map is null!")
	player.teleport(map.get_any_floor_point())
	enemy.map = map
	player.map = map
	# TODO fix this properly
	map.scale = Vector2(4, 4)


func set_map(p_map: GWJ30_Map) -> void:
	map = p_map
