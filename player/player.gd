extends Node2D
class_name GWJ30_Player


signal move
signal open_inventory()
signal took_item(item)
# I'm well aware the past tense of "put" is "put", but I can't have that
signal putted_item(item)


const REILLUMINATE_THRESHOLD := 30

export var map_path := NodePath()
#onready var map: GWJ30_Map = get_node(map_path)
onready var map = get_node(map_path)

onready var _visual: Node2D = get_node("Visual")
onready var _shadow: MeshInstance2D = get_node("Visual/Center shadow")

var items := [null, null, null]
var open_inventory_items := []
var illuminated := 0

var _interpolation_fraction := 0.0
var _old_position := Vector2()


func _ready() -> void:
	_visual.set_as_toplevel(true)
	_visual.scale = Vector2(4, 4)
	_visual.position = global_position
	_old_position = global_position
	_update_shadow()


func _process(delta: float) -> void:
	_interpolation_fraction = min(1.0, _interpolation_fraction + delta * 5.0)
	_visual.position = _old_position.linear_interpolate(global_position, ease(_interpolation_fraction, -1.75))


func move_left() -> void:
	_move(Vector2.LEFT)


func move_right() -> void:
	_move(Vector2.RIGHT)


func move_up() -> void:
	_move(Vector2.UP)


func move_down() -> void:
	_move(Vector2.DOWN)


func take_item(item) -> void:
	if null in items and item in open_inventory_items:
		items[items.find(null)] = item
		open_inventory_items[open_inventory_items.find(item)] = null
		emit_signal("took_item", item)


func put_item(item) -> void:
	if null in open_inventory_items and item in items:
		open_inventory_items[open_inventory_items.find(null)] = item 
		items[items.find(item)] = null
		emit_signal("putted_item", item)


func light_candle() -> void:
	if illuminated < REILLUMINATE_THRESHOLD and "Candle" in items:
		items[items.find("Candle")] = null
		illuminated = 100
		_update_shadow()
		emit_signal("took_item", "Candle")


func _move(direction: Vector2) -> void:
	open_inventory_items = []
	_old_position = global_position
	var result: GWJ30_TileActionResult = map.do_action(self, direction)
	if result == null:
		return
	if illuminated > 0:
		illuminated -= 1
		_update_shadow()
	_interpolation_fraction = 0.0
	emit_signal("move")
	if result is GWJ30_TileActionResult_None:
		pass
	elif result is GWJ30_TileActionResult_Inventory:
		open_inventory_items = result.items
		emit_signal("open_inventory")
	else:
		assert(false, "Unhandled result type")


func _update_shadow() -> void:
	_shadow.material.set_shader_param("shadow_radius", clamp(illuminated / float(REILLUMINATE_THRESHOLD), 0, 1))
