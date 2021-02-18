extends Node


func play() -> void:
	randomize()
	get_tree().change_scene("res://default_scenario.tscn")


func exit() -> void:
	get_tree().quit()
