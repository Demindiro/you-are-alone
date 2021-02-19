extends VBoxContainer

signal selected(item)

func _ready() -> void:
	var group := ButtonGroup.new()
	var i := 0
	for c in get_children():
		c.group = group
		var e: int = c.connect("pressed", self, "emit_signal", ["selected", i])
		assert(e == OK)
		i += 1
