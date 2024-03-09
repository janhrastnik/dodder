extends Area2D

var is_colliding = false
@onready var attach_label: Label = get_node("Attach Label")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if body is Dodder:
		is_colliding = true
		attach_label.visible = true
		animation_player.play("text_popup")
		body.attachable_plant = self


func _on_body_exited(body):
	if body is Dodder:
		is_colliding = false
		attach_label.visible = false
		body.attachable_plant = null
