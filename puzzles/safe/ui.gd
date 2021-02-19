extends Control


export var value_path := NodePath()
export var solution_path := NodePath()
onready var value: Label = get_node(value_path)
onready var solution: Control = get_node(solution_path)

var puzzle


func _ready() -> void:
	# Add whitespace to fix padding
	value.text = " " + str(puzzle.value)

	for s in puzzle.clues:
		var l := Label.new()
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL 
		if s >= 0:
			l.text = str(s)
		solution.add_child(l)


func increase() -> void:
	puzzle.increase()
	value.text = " " + str(puzzle.value)


func decrease() -> void:
	puzzle.decrease()
	value.text = " " + str(puzzle.value)
