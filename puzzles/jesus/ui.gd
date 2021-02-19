extends Control

var has_bread := false
var has_wine := false
var has_nail := false

export var bread_path := NodePath()
export var wine_path := NodePath()
export var nail_path := NodePath()
onready var bread: Control = get_node(bread_path)
onready var wine: Control = get_node(wine_path)
onready var nail: Control = get_node(nail_path)

func _ready() -> void:
	bread.visible = has_bread
	wine.visible = has_wine
	nail.visible = has_nail
