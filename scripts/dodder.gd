class_name Dodder

extends CharacterBody2D

@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
var attachable_plant: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func move_to(click_pos: Vector2):
	var diff = click_pos - position
	var diff_normed = diff.normalized()
	var dist = diff.length()
	var steps = int(dist / 32)
	var intermediary_points = []
	for i in range(1, steps+1):
		intermediary_points.append(position + diff_normed*32*i)
	intermediary_points.append(click_pos)
	while !intermediary_points.is_empty():
		var point = intermediary_points.pop_front()
		animation_player.play("shrink")
		await get_tree().create_timer(0.3).timeout
		position = point
		animation_player.play("grow")
		await get_tree().create_timer(0.3).timeout

func attach():
	pass
