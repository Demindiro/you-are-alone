extends GWJ30_TileAction_Puzzle
class_name GWJ30_TileAction_Puzzle_Door

class Puzzle:
	extends GWJ30_TileActionResult_Puzzle
	var key := ""
	var solved := false
	var map#:GWJ30_Map
	var position := Vector2()

	# TODO report a bug ("Unresolved" type)
	#func _init(owner: GWJ30_TileAction_Puzzle_Door) -> void:

	func put_item(item: String) -> bool:
		if not solved and item == key:
			solved = true
			var node: Node2D = preload("light.tscn").instance()
			map.add_child(node)
			node.position = position * 16 # TODO don't hardcode this
			# Don't emit a signal so the player has to step through the door manually
			# That's extra dramatic & stuff
			return true
		return false

	func get_ui() -> Control:
		if solved:
			return Control.new()
		else:
			return preload("ui.tscn").instance() as Control # godot pls

	func is_solved() -> bool:
		return solved

const _COUNTER := [0]
var puzzle := Puzzle.new()

func _init() -> void:
	name = "Door"
	puzzle.key = "Key"
	puzzle.owner = weakref(self)

func get_necessary_items() -> PoolStringArray:
	return PoolStringArray([puzzle.key])

func is_solved() -> bool:
	return puzzle.solved

func do(player: GWJ30_Player) -> GWJ30_TileActionResult:
	if puzzle.solved:
		player.position = position
		return GWJ30_TileActionResult_Escaped.new()
	else:
		puzzle.map = map # TODO hacky
		puzzle.position = position # TODO ditto
		return puzzle
