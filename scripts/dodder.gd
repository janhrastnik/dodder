class_name Dodder

extends CharacterBody2D

## To je class za dodder, ki se premika naokrog in ni attached na ničemer.

@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var hivemind: HivemindSingleton = get_node("/root/Hivemind")
var attachable_plant: Node2D = null # TODO: kasneje bi mel tuki nek base Plant class type

func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("attach"):
		if attachable_plant:
			attach()

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
		animation_player.play("grow")
		await get_tree().create_timer(0.3).timeout

## dodder se attacha na plant. Zbrišemo ta physical dodder entity. 
## V hivemind singleton (naš globalni gamedata) shranimo spremembo.
func attach():
	attachable_plant.attach()
	hivemind.is_attached = true
	hivemind.attached_plant = attachable_plant
	get_parent().get_node("Camera2D").slide(attachable_plant.position)
	queue_free()
