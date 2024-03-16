class_name Dodder
extends Area2D

## To je class za dodder, ki se premika naokrog in ni attached na ničemer.
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var hivemind: HivemindSingleton = get_node("/root/Hivemind")
@onready var step_sound: AudioStreamPlayer = get_node("StepSound")

var nutrients : int = 100
var plant: Plant = null

var state = States.Detached
enum States {
	Attached,
	Detached
}

var is_moving = false

var has_double_strand = false

# hack, to know when to not display the dodder ui info label
var areacount = 0

func _ready():
	get_parent().refresh_nutrient_count(nutrients)

func _input(event):
	if event.is_action_pressed("click") and state == States.Detached and not is_moving:
		var p = get_global_mouse_position()
		if p.x < -64 or p.y < -64  or p.x > 576 or p.y > 576:
			print("out of bounds!")
		else:
			move_to(p)
			get_parent().move_cam(p)
	match state:
		States.Detached:
			if event.is_action_pressed("attach") and plant and not plant.is_animating:
				if not plant.is_depleted:
					attach()
		States.Attached:
			if event.is_action_pressed("detach") and plant and not plant.is_animating:
				detach()
	
## Fancy movement funkcija. vzame razdaljo med klikom in trenutno pozicijo,
## določi vmesne korake za "animacijo", in se postopoma premakne po teh korakih.
## Vzamemo en korak na vsakih 32 pikslov razdalje.
func move_to(click_pos: Vector2):
	is_moving = true
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
		change_nutrients(-1) # stane 1 nutrient, da se premakneš
		step_sound.play()
		animation_player.play("grow")
		await get_tree().create_timer(0.3).timeout
	is_moving = false

## dodder se attacha na plant. Zbrišemo ta physical dodder entity. 
## V hivemind singleton (naš globalni gamedata) shranimo spremembo.
func attach():
	plant.attach(self)
	
	set_colisions_disabled(true)
	
	state = States.Attached
	visible = false
	get_parent().move_cam(plant.global_position)
	get_parent().dodder_attached_event()

func detach():
	plant.detach()
	
	set_colisions_disabled(false)
	
	state = States.Detached
	position = plant.global_position + Vector2(0, 15)
	visible = true
	get_parent().move_cam(position)
	#get_parent().dodder_hide_info_text()

func change_nutrients(amount : int) -> void:
	nutrients += amount
	get_parent().refresh_nutrient_count(nutrients)

func set_colisions_disabled(b : bool) -> void:
	$CollisionShape2D.disabled = b

func _on_area_entered(area):
	if area is Plant:
		plant = area
		get_parent().dodder_attachable_event(plant.is_depleted)
	areacount += 1


func _on_area_exited(area):
	areacount -= 1
	if areacount == 0 and state == States.Detached:
		get_parent().dodder_hide_info_text()
		plant = null
