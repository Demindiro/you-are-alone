extends GWJ30_TileAction_Puzzle
class_name GWJ30_TileAction_Puzzle_Jesus

class Puzzle:
	extends GWJ30_TileActionResult_Puzzle
	var has_bread := false
	var has_wine := false
	var has_nail := false

	func put_item(item: String) -> bool:
		var placed := false
		match item:
			"Bread":
				if not has_bread:
					has_bread = true
					placed = true
			"Wine":
				if not has_wine:
					has_wine = true
					placed = true
			"Nail":
				if not has_nail:
					has_nail = true
					placed = true
		if placed and has_bread and has_wine and has_nail:
			emit_signal("solved")
		return placed 

	func get_ui() -> Control:
		var c: Control = preload("ui.tscn").instance()
		c.has_bread = has_bread
		c.has_wine = has_wine
		c.has_nail = has_nail
		return c

var puzzle := Puzzle.new()
var inventory := GWJ30_TileActionResult_Inventory.new([null])

func _init() -> void:
	name = "Cross"
	items = inventory.items
	puzzle.owner = weakref(self)

func get_necessary_items() -> PoolStringArray:
	return PoolStringArray(["Bread", "Wine", "Nail"])

func is_solved() -> bool:
	return puzzle.has_bread and puzzle.has_wine and puzzle.has_nail

func do(player: GWJ30_Player) -> GWJ30_TileActionResult:
	if is_solved():
		return inventory
	else:
		return puzzle
