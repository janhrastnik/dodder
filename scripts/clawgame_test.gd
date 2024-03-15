extends Area2D

func _on_body_entered(body):
	var clawgame = load("res://scenes/minigames/clawgame.tscn")
	var clawgame_instance: CanvasLayer = clawgame.instantiate()
	
	add_child(clawgame_instance)
