extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_how_to_play_pressed():
	pass # Replace with function body.

func _on_button_pressed():
	var map = load("res://scenes/map.tscn")
	get_tree().change_scene_to_packed(map)
