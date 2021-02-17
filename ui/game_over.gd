extends ColorRect


func restart() -> void:
	print("ME RESTART")
	get_tree().reload_current_scene()


func exit() -> void:
	pass # TODO goto main menu
