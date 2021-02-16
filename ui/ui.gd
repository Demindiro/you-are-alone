extends CanvasLayer


export var player_path := NodePath()
export var chest_inventory_path := NodePath()
export var self_inventory_path := NodePath()
onready var player: GWJ30_Player = get_node(player_path)
onready var chest_inventory: Control = get_node(chest_inventory_path)
onready var self_inventory: Control = get_node(self_inventory_path)

export var move_left_button_path := NodePath()
export var move_right_button_path := NodePath()
export var move_up_button_path := NodePath()
export var move_down_button_path := NodePath()
onready var move_left_button: BaseButton = get_node(move_left_button_path)
onready var move_right_button: BaseButton = get_node(move_right_button_path)
onready var move_up_button: BaseButton = get_node(move_up_button_path)
onready var move_down_button: BaseButton = get_node(move_down_button_path)


func _ready() -> void:
	var e := player.connect("move", self, "move")
	assert(e == OK)
	e = player.connect("open_inventory", self, "open_inventory")
	assert(e == OK)
	e = player.connect("took_item", self, "took_item")
	assert(e == OK)
	e = player.connect("putted_item", self, "putted_item")
	assert(e == OK)
	e = move_left_button.connect("pressed", player, "move_left")
	assert(e == OK)
	e = move_right_button.connect("pressed", player, "move_right")
	assert(e == OK)
	e = move_up_button.connect("pressed", player, "move_up")
	assert(e == OK)
	e = move_down_button.connect("pressed", player, "move_down")
	assert(e == OK)
	_refresh_inventory()


func move() -> void:
	clear_children(chest_inventory)
	_refresh_actions()


func open_inventory() -> void:
	_refresh_inventory()


func took_item(_item) -> void:
	_refresh_inventory()


# See note in player.gd
func putted_item(_item) -> void:
	_refresh_inventory()


func take_item(item):
	player.take_item(item)


func put_item(item):
	player.put_item(item)


func _refresh_inventory() -> void:
	clear_children(self_inventory)
	clear_children(chest_inventory)
	for e in player.items:
		if e == null:
			e = ""
		var btn := Button.new()
		btn.rect_min_size = Vector2.ONE * 96
		btn.text = e
		var err := btn.connect("pressed", self, "put_item", [e])
		assert(err == OK)
		self_inventory.add_child(btn)
	for e in player.open_inventory_items:
		if e == null:
			e = ""
		var btn := Button.new()
		btn.rect_min_size = Vector2.ONE * 96
		btn.text = e
		var err := btn.connect("pressed", self, "take_item", [e])
		assert(err == OK)
		chest_inventory.add_child(btn)


func _refresh_actions() -> void:
	var actions: GWJ30_TileActionList = player.map.get_actions(player)
	var btn_act := [
		[move_left_button, actions.left],
		[move_right_button, actions.right],
		[move_up_button, actions.up],
		[move_down_button, actions.down],
	]
	for ba in btn_act:
		var b: Button = ba[0]
		var a: GWJ30_TileAction = ba[1]
		b.text = a.name
		b.disabled = a.name == ""
		if b.disabled:
			b.call_deferred("release_focus")


static func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
		# Remove child to prevent messing up the layout in case more
		# get added
		node.remove_child(child)
