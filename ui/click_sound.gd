extends Node


func play() -> void:
	get_child(randi() % get_child_count()).play()
