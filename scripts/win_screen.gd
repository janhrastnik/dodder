extends CanvasLayer

func _input(event):
	if event.is_action_pressed("detach"):
		var menu = load("res://scenes/menu.tscn")
		get_tree().change_scene_to_packed(menu)
