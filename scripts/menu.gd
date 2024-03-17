extends CanvasLayer

@onready var how_to_play = get_node("How To Play Panel")

func _input(event):
	if event.is_action_pressed("detach"):
		how_to_play.hide()

func _on_how_to_play_pressed():
	how_to_play.show()

func _on_button_pressed():
	var map = load("res://scenes/map.tscn")
	get_tree().change_scene_to_packed(map)
