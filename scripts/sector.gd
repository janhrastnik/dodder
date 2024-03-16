class_name Sector
extends Sprite2D

@export var sector_data: SectorData
var sector: String

const WIDTH = 128
const HEIGHT = 128

var rng = RandomNumberGenerator.new()

# plant
var basic_bush = load("res://scenes/plants/basic_bush.tscn")
var fancy_bush = load("res://scenes/plants/fancy_bush.tscn")
var basic_tree = load("res://scenes/plants/basic_tree.tscn")
var fancy_tree = load("res://scenes/plants/fancy_tree.tscn")

# ground
var basic_grass = load("res://textures/basic_grass.png")
var basic_grass2 = load("res://textures/basic_grass2.png")
var basic_forest = load("res://textures/basic_forest.png")
var basic_forest2 = load("res://textures/basic_forest2.png")
var pond_packed = load("res://scenes/pond.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
	sector = sector_data.sector_type

	if sector == "Pond":
		var pond_instance = pond_packed.instantiate()
		add_child(pond_instance)
	elif sector == "BasicForest":
		var coinflip = randi_range(1, 2)
		if coinflip == 1:
			texture = basic_forest
		else:
			texture = basic_forest2
		
		var plant_count = rng.randi_range(3, 8)
		for i in range(plant_count):
			var fancy_check = randi_range(1, 10)
			if fancy_check == 10:
				spawn_plant_on_random_point(fancy_tree)
			else:
				spawn_plant_on_random_point(basic_tree)
	elif sector == "BasicGrass":
		var coinflip = randi_range(1, 2)
		if coinflip == 1:
			texture = basic_grass
		else:
			texture = basic_grass2
		
		var plant_count = rng.randi_range(3, 8)
		for i in range(plant_count):
			var fancy_check = randi_range(1, 10)
			if fancy_check == 10:
				spawn_plant_on_random_point(fancy_bush)
			else:
				spawn_plant_on_random_point(basic_bush)

func spawn_plant_on_random_point(plant: PackedScene):
	var plant_instance: Plant = plant.instantiate()
	
	var x = rng.randi_range(-WIDTH/2, WIDTH/2)
	var y = rng.randi_range(-HEIGHT/2, HEIGHT/2)
	
	plant_instance.position = Vector2(x,y)
	
	add_child(plant_instance)
