class_name Dodder
extends CharacterBody2D

## To je class za dodder, ki se premika naokrog in ni attached na ničemer.
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var hivemind: HivemindSingleton = get_node("/root/Hivemind")
@onready var step_sound: AudioStreamPlayer = get_node("StepSound")

var nutrients : int = 0
var plant: Plant = null 

var state = States.Detached
enum States {
	Attached,
	Detached
}

func _input(event):
	if event.is_action_pressed("click") and state == States.Detached:
		var p = get_global_mouse_position()
		move_to(p)
		get_parent().move_cam(p)

func _process(delta):
	match state:
		States.Detached:
			if Input.is_action_just_pressed("attach") and plant:
				attach()
		
		States.Attached:
			if Input.is_action_just_pressed("detach") and plant:
				detach()
	
## Fancy movement funkcija. vzame razdaljo med klikom in trenutno pozicijo,
## določi vmesne korake za "animacijo", in se postopoma premakne po teh korakih.
## Vzamemo en korak na vsakih 32 pikslov razdalje.
func move_to(click_pos: Vector2):
	var diff = click_pos - position # vektor od dodderja do klika
	var dist = diff.length()
	var step_count = int(dist / 32) # število vmesnih korakov
	var steps = []
	
	for i in range(1, step_count+1):
		steps.append(position + diff.normalized()*32*i)
	steps.append(click_pos)
	
	while !steps.is_empty():
		var point = steps.pop_front()
		animation_player.play("shrink")
		await get_tree().create_timer(0.3).timeout # počakamo da se animacija zaključi, preden se premaknemo
		position = point
		step_sound.play()
		animation_player.play("grow")
		await get_tree().create_timer(0.3).timeout

## dodder se attacha na plant. Zbrišemo ta physical dodder entity. 
## V hivemind singleton (naš globalni gamedata) shranimo spremembo.
func attach():
	plant.attach(self)
	
	set_colisions_disabled(true)
	
	state = States.Attached
	visible = false
	
	get_parent().move_cam(plant.position)
	get_parent().dodder_attached_event()

func detach():
	plant.detach()
	
	set_colisions_disabled(false)
	
	state = States.Detached
	position = plant.position + Vector2(0, 15)
	visible = true

	get_parent().move_cam(position)
	get_parent().dodder_detached_event()

func gain_nutrients(amount : int) -> void:
	nutrients += amount
	get_parent().refresh_nutrient_count(nutrients)

func set_colisions_disabled(b : bool) -> void:
	$CollisionShape2D.disabled = b
	$Area2D/CollisionShape2D.disabled = b

func _on_area_2d_area_entered(area):
	if area is Plant:
		plant = area
