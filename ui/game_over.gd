extends ColorRect


func restart() -> void:
	print("ME RESTART")
	get_tree().reload_current_scene()


func exit() -> void:
	get_tree().change_scene("res://main_menu.tscn")
