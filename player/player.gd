extends Sprite
class_name GWJ30_Player


signal move
signal open_inventory()
signal took_item(item)
# I'm well aware the past tense of "put" is "put", but I can't have that
signal putted_item(item)


export var map_path := NodePath()
#onready var map: GWJ30_Map = get_node(map_path)
onready var map = get_node(map_path)


var items := [null, null, null]
var open_inventory_items := []


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


func _move(direction: Vector2) -> void:
	var result: GWJ30_TileActionResult = map.do_action(self, direction)
	if result == null:
		return
	emit_signal("move")
	if result is GWJ30_TileActionResult_None:
		pass
	elif result is GWJ30_TileActionResult_Inventory:
		open_inventory_items = result.items
		emit_signal("open_inventory")
	else:
		assert(false, "Unhandled result type")
