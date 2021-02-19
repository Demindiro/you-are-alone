extends CenterContainer


func exit() -> void:
	get_tree().change_scene("res://main_menu.tscn")


func cancel() -> void:
	visible = false
