class_name FancyBush

extends Area2D

## Trenutno sam uporabljam to kot test za stemrunner

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if body is Dodder:
		var stemrunner = load("res://scenes/stemrunner/stemrunner.tscn")
		var stemrunner_instance: CanvasLayer = stemrunner.instantiate()
		
		add_child(stemrunner_instance)

	
func _on_body_exited(body):
	if body is Dodder:
		pass
