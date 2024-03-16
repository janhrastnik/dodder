class_name ClawGame

extends CanvasLayer

@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var claw: TextureRect = get_node("Background/Claw")
@onready var dna: TextureRect = get_node("Background/DNA")
@onready var win_sound: AudioStreamPlayer = get_node("WinSound")
@onready var loss_sound: AudioStreamPlayer = get_node("LossSound")
@onready var drop_sound: AudioStreamPlayer = get_node("DropSound")

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("claw_movement")
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var x = rng.randi_range(64, 448)
	dna.position.x = x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("down"):
		claw_drop()

func claw_drop():
	drop_sound.play()
	var claw_open = load("res://textures/clawgame/claw_open.png")
	claw.texture = claw_open
	animation_player.pause()
	
	var lib = AnimationLibrary.new()
	
	var animation = Animation.new()
	animation.length = 3.0
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Background/Claw:position:y")
	animation.track_insert_key(track_index, 0.0, 0)
	animation.track_insert_key(track_index, 3.0, 416)
	lib.add_animation("drop", animation)
	
	animation_player.add_animation_library("claw", lib)
	animation_player.play("claw/drop")
	await get_tree().create_timer(3.0).timeout
	
	var diff = abs(claw.position.x - dna.position.x)
	if diff < 36:
		win()
	else:
		loss()

func win():
	var lib = AnimationLibrary.new()
	
	win_sound.play()
	
	# fix dna position
	dna.position.x = claw.position.x
	
	var animation = Animation.new()
	animation.length = 3.0	
	var track_index_claw = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index_claw, "Background/Claw:position:y")
	animation.track_insert_key(track_index_claw, 0.0, 416)
	animation.track_insert_key(track_index_claw, 3.0, 0)
	
	var track_index_dna = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index_dna, "Background/DNA:position:y")
	animation.track_insert_key(track_index_dna, 0.0, 448)
	animation.track_insert_key(track_index_dna, 3.0, 32)

	lib.add_animation("hoist", animation)
	
	animation_player.add_animation_library("win", lib)
	
	animation_player.play("win/hoist")
	
	await get_tree().create_timer(3.0).timeout
	
	get_parent().clawgame_win()

func loss():
	loss_sound.play()
	
	await get_tree().create_timer(3.0).timeout
	
	get_parent().clawgame_loss()
