extends Node


export var shadow_path := NodePath()
onready var shadow: MeshInstance2D = get_node(shadow_path)


func _ready() -> void:
	shadow.material.set_shader_param("shadow_radius", 1.0)


func play() -> void:
	randomize()
	get_tree().change_scene("res://default_scenario.tscn")


func exit() -> void:
	get_tree().quit()
