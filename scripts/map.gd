extends Node2D

## Trenutno je to node za map. Zaenkrat tukaj spawnamo stvari,
## in handlamo click event za premik dodderja.

const WIDTH = 640 # potrebno za spawning
const HEIGHT = 640

@onready var hivemind: HivemindSingleton = get_node("/root/Hivemind") # global gamedata
@onready var camera: Camera2D = get_node("Camera2D")
@onready var dodder_ui: CanvasLayer = get_node("Dodder UI")
@onready var click_circle: AnimatedSprite2D = get_node("Click Circle")
@onready var music: AudioStreamPlayer = get_node("Music")
@onready var out_of_bounds_label: Label = get_node("Out Of Bounds Label")
var dodder: Dodder = null # the player

var sector_scene = load("res://scenes/sector.tscn")
var dodder_scene = load("res://scenes/dodder/dodder.tscn")

var rng = RandomNumberGenerator.new()

func _ready():
	spawn_baby_dodder()
	create_map()
	create_border()
	rng.randomize()

func _input(event):
	if event.is_action_pressed("click"):
		if dodder:
			var pos = get_local_mouse_position()
			if pos.x < -64 or pos.y < -64 or pos.x > 576 or pos.y > 576:
				out_of_bounds_animation(pos)
			else:
				click_animation(pos)

func move_cam(pos : Vector2) -> void:
	camera.slide(pos)

func spawn_baby_dodder():
	var dodder_instance: Dodder = dodder_scene.instantiate()
	
	dodder_instance.position = Vector2(WIDTH/2,HEIGHT/2)
	dodder = dodder_instance
	
	add_child(dodder_instance)

func create_map():
	var lottery = Array(range(25))
	var pond_index = randi_range(0, 24)
	lottery.remove_at(pond_index)
	
	var index = 0
	
	var forest_indices = []
	for i in range(5):
		var forest_index = randi_range(0, len(lottery)-1)
		forest_indices.append(lottery[forest_index])
		lottery.remove_at(forest_index)
	
	for y in range(5):
		for x in range(5):
			if index == pond_index:
				add_sector(x*128, y*128, "Pond")
			elif index in forest_indices:
				add_sector(x*128, y*128, "BasicForest")
			else:
				add_sector(x*128, y*128, "BasicGrass")
			index += 1

func add_sector(x: int, y: int, sector_type: String):
	var sector_instance: Sector = sector_scene.instantiate()
	sector_instance.position.x = x
	sector_instance.position.y = y
	
	var sector_data = SectorData.new()
	sector_data.sector_type = sector_type
	
	sector_instance.sector_data = sector_data
	add_child(sector_instance)

func create_border():
	# corners
	var corner_left_up = Sprite2D.new()
	corner_left_up.texture = load("res://textures/border/corner-left-up.png")
	corner_left_up.global_position = Vector2(-128, -128)

	var corner_right_up = Sprite2D.new()
	corner_right_up.texture = load("res://textures/border/corner-right-up.png")
	corner_right_up.position = Vector2(640, -128)

	var corner_left_down = Sprite2D.new()
	corner_left_down.texture = load("res://textures/border/corner-left-down.png")
	corner_left_down.position = Vector2(-128, 640)

	var corner_right_down = Sprite2D.new()
	corner_right_down.texture = load("res://textures/border/corner-right-down.png")
	corner_right_down.position = Vector2(640, 640)

	for i in range(5):
		var pipe_up = Sprite2D.new()
		pipe_up.texture = load("res://textures/border/pipe-h-up.png")
		pipe_up.position = Vector2(i * 128, -128)
		add_child(pipe_up)

		var pipe_down = Sprite2D.new()
		pipe_down.texture = load("res://textures/border/pipe-h-down.png")
		pipe_down.position = Vector2(i * 128, 640)
		add_child(pipe_down)

		var pipe_left = Sprite2D.new()
		pipe_left.texture = load("res://textures/border/pipe-v-left.png")
		pipe_left.position = Vector2(-128, i * 128)
		add_child(pipe_left)

		var pipe_right = Sprite2D.new()
		pipe_right.texture = load("res://textures/border/pipe-v-right.png")
		pipe_right.position = Vector2(640, i * 128)
		add_child(pipe_right)

	add_child(corner_left_up)
	add_child(corner_right_up)
	add_child(corner_left_down)
	add_child(corner_right_down)

func click_animation(loc: Vector2):
	click_circle.position = loc
	click_circle.visible = true
	click_circle.play("click")

func out_of_bounds_animation(loc: Vector2):
	out_of_bounds_label.position = loc
	out_of_bounds_label.show()
	await get_tree().create_timer(2).timeout
	out_of_bounds_label.hide()

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

func update_dna_strand_ui(strand: String):
	dodder_ui.show_dna_strand(strand)

func _on_music_finished():
	music.play()
