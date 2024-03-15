class_name Sector
extends Sprite2D

@export var sector_data: SectorData
var sector: String

const WIDTH = 128
const HEIGHT = 128

var rng = RandomNumberGenerator.new()

var basic_bush = load("res://scenes/plants/basic_bush.tscn")
var basic_grass = load("res://textures/ground_block.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
	sector = sector_data.sector_type

	if sector == "BasicGrass":
		#print("here")
		texture = basic_grass
		
		var plant_count = rng.randi_range(3, 8)
		for i in range(plant_count):
			spawn_plant_on_random_point("basic_bush")

func spawn_plant_on_random_point(plant_name: String):
	var plant;
	if plant_name == "basic_bush":
		plant = basic_bush
	var plant_instance: Area2D = plant.instantiate()
	
	var x = rng.randi_range(-WIDTH/2, WIDTH/2)
	var y = rng.randi_range(-HEIGHT/2, HEIGHT/2)
	
	plant_instance.position = Vector2(x,y)
	
	add_child(plant_instance)
