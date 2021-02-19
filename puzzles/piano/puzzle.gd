extends GWJ30_TileAction_Puzzle
class_name GWJ30_TileAction_Puzzle_Piano

class Puzzle:
	extends GWJ30_TileActionResult_Puzzle
	var notes := PoolIntArray()
	var solution := PoolIntArray()

	const LENGTH := 4
	const PITCHES := 3

	func _init() -> void:
		for i in LENGTH:
			solution.push_back(randi() % PITCHES)

	func put_item(item: String) -> bool:
		if item == "Button":
			notes.push_back(-1)
			return true
		return false

	func get_ui() -> Control:
		var c: Control = preload("ui.tscn").instance()
		c.puzzle = self
		return c

	func set_note(note: int, pitch: int) -> void:
		notes[note] = pitch
		if notes == solution:
			emit_signal("solved")

var puzzle := Puzzle.new()
var inventory := GWJ30_TileActionResult_Inventory.new([null])

func _init() -> void:
	name = "Piano"
	items = inventory.items
	puzzle.owner = weakref(self)

func get_necessary_items() -> PoolStringArray:
	var a := PoolStringArray()
	for _i in Puzzle.LENGTH:
		a.push_back("Button")
	return a

func is_solved() -> bool:
	return puzzle.notes == puzzle.solution

func do(player: GWJ30_Player) -> GWJ30_TileActionResult:
	if is_solved():
		return inventory
	else:
		return puzzle
