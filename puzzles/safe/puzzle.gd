extends GWJ30_TileAction_Puzzle
class_name GWJ30_TileAction_Puzzle_Safe

class Puzzle:
	extends GWJ30_TileActionResult_Puzzle

	const STR_TO_NUM := {
		"Zero": 0,
		"One": 1,
		"Two": 2,
		"Three": 3,
		"Four": 4,
		"Five": 5,
		"Six": 6,
		"Seven": 7,
		"Eight": 8,
		"Nine": 9,
	}
	const LENGTH := 5

	var solution := PoolIntArray()
	var clues := PoolIntArray()
	var solved := false
	var value := 0
	var step := 0
	var current_solution := -1

	func _init() -> void:
		var a := []
		for i in 10:
			a.push_back(i)
		a.shuffle()
		for _i in LENGTH:
			solution.push_back(a.pop_back())
			clues.push_back(-1)

	func put_item(item: String) -> bool:
		var n: int = STR_TO_NUM.get(item, -1)
		if n in solution and not n in clues:
			clues[Array(solution).find(n)] = n
			return true
		return false

	func get_ui() -> Control:
		var c: Control = preload("ui.tscn").instance()
		c.puzzle = self
		return c

	func increase() -> void:
		value = posmod(value + 1, 10)
		if value == current_solution:
			step += 1
			if step == LENGTH:
				solved = true
				emit_signal("solved")
			else:
				current_solution = solution[step]
		elif value > current_solution:
			# Wrong direction, reset
			step = 0
			current_solution = solution[step]
	
	func decrease() -> void:
		value = posmod(value - 1, 10)
		if value == current_solution:
			step += 1
			if step == LENGTH:
				solved = true
				emit_signal("solved")
			else:
				current_solution = solution[step]
		elif value < current_solution:
			# Wrong direction, reset
			step = 0
			current_solution = solution[step]

const NUM_TO_STR := [
	"Zero",
	"One",
	"Two",
	"Three",
	"Four",
	"Five",
	"Six",
	"Seven",
	"Eight",
	"Nine",
]

var puzzle := Puzzle.new()
var inventory := GWJ30_TileActionResult_Inventory.new([null])

func _init() -> void:
	name = "Safe"
	items = inventory.items
	puzzle.owner = weakref(self)

func get_necessary_items() -> PoolStringArray:
	var a := PoolStringArray()
	for n in puzzle.solution:
		a.push_back(NUM_TO_STR[n])
	return a

func is_solved() -> bool:
	return puzzle.solved

func do(player: GWJ30_Player) -> GWJ30_TileActionResult:
	if is_solved():
		return inventory
	else:
		return puzzle
