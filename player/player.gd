extends Node2D
class_name GWJ30_Player


signal move
signal open_inventory
signal open_puzzle
signal took_item(item)
# I'm well aware the past tense of "put" is "put", but I can't have that
signal putted_item(item)
signal killed
signal escaped


const REILLUMINATE_THRESHOLD := 30

export var sprite_path := NodePath()
onready var sprite: AnimatedSprite = get_node(sprite_path)

export var map_path := NodePath()
#onready var map: GWJ30_Map = get_node(map_path)
onready var map = get_node_or_null(map_path)

onready var _visual: Node2D = get_node("Visual")
onready var _shadow: MeshInstance2D = get_node("Visual/Center shadow")

var items := [null, null, null]
var open_inventory_items := []
var puzzle#: GWJ30_Puzzle
var illuminated := 0

var _interpolation_fraction := 0.0
var _old_position := Vector2()


func _ready() -> void:
	_visual.set_as_toplevel(true)
	_visual.scale = Vector2(4, 4)
	teleport(position)
	_update_shadow()


func _process(delta: float) -> void:
	_interpolation_fraction = min(1.0, _interpolation_fraction + delta * 5.0)
	if _interpolation_fraction == 1.0:
		sprite.play("idle")
	elif global_position != _old_position:
		sprite.play("walking")
	_visual.position = _old_position.linear_interpolate(global_position, ease(_interpolation_fraction, -1.75))


func teleport(p_position: Vector2) -> void:
	position = p_position
	_visual.position = global_position
	_old_position = global_position


func move_left() -> void:
	sprite.flip_h = false
	_move(Vector2.LEFT)


func move_right() -> void:
	sprite.flip_h = true
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
	if item in items:
		if len(open_inventory_items) > 0:
			if null in open_inventory_items:
				open_inventory_items[open_inventory_items.find(null)] = item 
				items[items.find(item)] = null
				emit_signal("putted_item", item)
		elif puzzle != null:
			if puzzle.put_item(item):
				items[items.find(item)] = null
				emit_signal("putted_item", item)


func light_candle() -> void:
	if illuminated < REILLUMINATE_THRESHOLD and "Candle" in items:
		items[items.find("Candle")] = null
		illuminated = 100
		_update_shadow()
		emit_signal("took_item", "Candle")


func kill() -> void:
	emit_signal("killed")


func _puzzle_solved() -> void:
	var result: GWJ30_TileActionResult = puzzle.do(self)
	_clear_state()
	_parse_result(result)


func _clear_state() -> void:
	if puzzle != null:
		puzzle.disconnect("solved", self, "_puzzle_solved")
	puzzle = null
	open_inventory_items = []


func _move(direction: Vector2) -> void:
	_clear_state()
	_old_position = global_position
	var result: GWJ30_TileActionResult = map.do_action(self, direction)
	if result == null:
		return
	if illuminated > 0:
		illuminated -= 1
		_update_shadow()
	_interpolation_fraction = 0.0
	emit_signal("move")
	_parse_result(result)


func _parse_result(result: GWJ30_TileActionResult) -> void:
	if result is GWJ30_TileActionResult_None:
		pass
	elif result is GWJ30_TileActionResult_Inventory:
		open_inventory_items = result.items
		emit_signal("open_inventory")
	elif result is GWJ30_TileActionResult_Puzzle:
		puzzle = result
		var e: int = puzzle.connect("solved", self, "_puzzle_solved")
		assert(e == OK)
		emit_signal("open_puzzle")
	elif result is GWJ30_TileActionResult_Escaped:
		emit_signal("escaped")
	else:
		assert(false, "Unhandled result type")


func _update_shadow() -> void:
	_shadow.material.set_shader_param("shadow_radius", clamp(illuminated / float(REILLUMINATE_THRESHOLD), 0, 1))
