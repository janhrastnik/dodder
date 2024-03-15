extends Node2D

## Trenutno je to node za map. Zaenkrat tukaj spawnamo stvari,
## in handlamo click event za premik dodderja.

const WIDTH = 128 # potrebno za spawning
const HEIGHT = 128

@onready var hivemind: HivemindSingleton = get_node("/root/Hivemind") # global gamedata
@onready var camera: Camera2D = get_node("Camera2D")
@onready var dodder_ui: CanvasLayer = get_node("Dodder UI")
@onready var click_circle: AnimatedSprite2D = get_node("Click Circle")
@onready var music: AudioStreamPlayer = get_node("Music")
var dodder: Dodder = null # the player

func _ready():
	#spawn_plant_on_random_point("basic_bush")
	spawn_baby_dodder()
	create_map()

func _input(event):
	if event.is_action_pressed("click"):
		if dodder:
			#print(event.position)
			var pos = get_local_mouse_position()
			#dodder.move_to(pos)
			#camera.slide(pos)
			click_animation(pos)

func move_cam(pos : Vector2) -> void:
	camera.slide(pos)

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

func create_map():
	for y in range(5):
		for x in range(5):
			add_sector(x*128, y*128, "BasicGrass")

func add_sector(x: int, y: int, sector_type: String):
	var sector_scene = load("res://scenes/sector.tscn")
	var sector_instance: Sector = sector_scene.instantiate()
	sector_instance.position.x = x
	sector_instance.position.y = y
	
	var sector_data = SectorData.new()
	sector_data.sector_type = sector_type
	
	sector_instance.sector_data = sector_data
	add_child(sector_instance)

func click_animation(loc: Vector2):
	click_circle.position = loc
	click_circle.visible = true
	click_circle.play("click")

func _on_click_circle_animation_finished():
	click_circle.stop()
	click_circle.visible = false

## Tukaj osvežimo par ui elementov
func dodder_attached_event():
	dodder_ui.attached_event()

func dodder_attachable_event(is_depleted: bool):
	dodder_ui.attachable_event(is_depleted)

func dodder_hide_info_text():
	dodder_ui.hide_info_text()

func refresh_nutrient_count(nutrients: int):
	dodder_ui.refresh_nutrient_count(nutrients)

func _on_music_finished():
	music.play()
