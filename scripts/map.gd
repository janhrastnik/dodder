extends Node2D

const WIDTH = 128
const HEIGHT = 128

@onready var hivemind: HivemindSingleton = get_node("/root/Hivemind")
@onready var camera: Camera2D = get_node("Camera2D")
var dodder: Dodder = null

func _ready():
	spawn_plant_on_random_point("basic_bush")
	spawn_baby_dodder()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("click"):
		if dodder:
			#print(event.position)
			dodder.move_to(get_local_mouse_position())
			camera.slide(get_local_mouse_position())

func spawn_plant_on_random_point(plant_name: String):
	var plant = load("res://scenes/plants/{name}.tscn".format({name=plant_name}))
	var plant_instance: Area2D = plant.instantiate()
	
	var rng = RandomNumberGenerator.new()
	var x = rng.randi_range(0, WIDTH)
	var y = rng.randi_range(0, HEIGHT)
	
	plant_instance.translate(Vector2(x,y))
	
	add_child(plant_instance)

func spawn_baby_dodder():
	var dodder_scene = load("res://scenes/dodder/dodder.tscn")
	var dodder_instance: Dodder = dodder_scene.instantiate()
	
	dodder_instance.position = Vector2(WIDTH/2,HEIGHT/2)
	dodder = dodder_instance
	
	add_child(dodder_instance)
