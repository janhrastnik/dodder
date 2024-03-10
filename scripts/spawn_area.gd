extends Node2D

@export var plant : PackedScene
@export var amount : int
@export var radius : int

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	get_random_position()
	for i in range(amount):
		var p = plant.instantiate()
		var map = get_parent()
		p.position = to_global(get_random_position())
		map.add_child.call_deferred(p)

func get_random_position() -> Vector2:
	var x = rng.randi_range(-radius, radius)
	var y = rng.randi_range(-radius, radius)
	return Vector2(x,y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
