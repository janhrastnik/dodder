extends Node2D

## Dodder ko je attached na plant.
## Ali naj sploh bo to ločen class al naj vse bo v enem big dodder classu? I'm not sure
## Po eni strani je kul met seperated ker je clear divide v kaj eno drugo dela in bo koda
## malo bolj neatly organizirana. Po drugi strani se pa rabš zajebavat s spawnanjem 
## attached / not attached dodderjev.

## Basically ko je attached, hočmo delat dve stvari:
## 1. harvesting nutrients
## 2. dna theft

## TODO: possibly nek combat mechanic or something?
## Da rabš infiltrirat v plant netrunner style, alpa da so traps lah not če si preveč časa attached
## Alpa da te nek human walking by lahko pokropi z nekim pesticidom

@onready var hivemind: HivemindSingleton = get_node("/root/Hivemind")
var attached_plant = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("detach"):
		if attached_plant:
			detach()

func detach():
	attached_plant.detach()
	
	var dodder = load("res://scenes/dodder/dodder.tscn")
	var dodder_instance: Node2D = dodder.instantiate()
	dodder_instance.position = attached_plant.position + Vector2(0, 15)
	get_parent().add_child(dodder_instance)
	
	hivemind.is_attached = true
	hivemind.attached_plant = null
	get_parent().dodder = dodder_instance
	get_parent().dodder_detached_event()
	get_parent().get_node("Camera2D").slide(dodder_instance.position)
	queue_free()
