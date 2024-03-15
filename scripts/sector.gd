class_name Sector
extends Sprite2D

@export var sector_data: SectorData
var sector: String

const WIDTH = 128
const HEIGHT = 128

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
	sector = sector_data.sector_type

	if sector == "BasicGrass":
		#print("here")
		var ground_sprite = load("res://textures/ground_block.png")
		texture = ground_sprite
		
		var plant_count = rng.randi_range(5, 10)
		for i in range(plant_count):
			spawn_plant_on_random_point("basic_bush")

func spawn_plant_on_random_point(plant_name: String):
	var plant = load("res://scenes/plants/{name}.tscn".format({name=plant_name}))
	var plant_instance: Area2D = plant.instantiate()
	
	var rng = RandomNumberGenerator.new()
	var x = rng.randi_range(-WIDTH/2, WIDTH/2)
	var y = rng.randi_range(-HEIGHT/2, HEIGHT/2)
	
	plant_instance.position = Vector2(x,y)
	
	add_child(plant_instance)
