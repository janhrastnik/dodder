class_name Plant
extends Area2D

## The plant node.
## You need to add a "Sprite" Sprite2D node , "Shape" CollisionShape2D node,
## and a AnimationPlayer node for this to work properly.

# plant stats
var dodder: Dodder = null
@export var stats: PlantStats
var plant_name: String
var nutrient_count: int
var nutrient_yield: int

# needed nodes
var popup_text: Node2D = null
var qte_timer: Timer = null
var start_timer: Timer = null
var qte_display : HBoxContainer = null
@onready var sprite: AnimatedSprite2D = get_node("Sprite")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var shape: CollisionShape2D = get_node("Shape")

var shake_sound: AudioStreamPlayer = null
var harvest_sound: AudioStreamPlayer = null
var qte_indicator_sound: AudioStreamPlayer = null
var qte_failure_sound: AudioStreamPlayer = null

# qte številka ki jo player mora pritisnit
var qte_prompt = null

# ko reachamo 0, se začne qte
var qte_countdown = null

var is_depleted = false # ko nutrient_count reacha 0
var is_animating = false # da lahko "zamrznemo" ene stvari
var has_stemrunner = false
var is_harvest_phase = false

# dna strands
var dna_strand = null

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	plant_name = stats.name
	nutrient_count = stats.nutrient_count
	nutrient_yield = stats.nutrient_yield
	has_stemrunner = stats.has_stemrunner
	
	rng.randomize()
	
	# construct subnodes
	var popup_text_packed = load("res://scenes/ui/popup_text.tscn")
	popup_text = popup_text_packed.instantiate()
	popup_text.get_node("Label").text = stats.name
	add_child(popup_text)
	
	qte_timer = Timer.new()
	qte_timer.one_shot = true
	qte_timer.name = "QTE Timer"
	add_child(qte_timer)

	start_timer = Timer.new()
	start_timer.name = "Start Timer"
	add_child(start_timer)
	
	var qte_display_packed = load("res://scenes/plants/qte_container.tscn")
	qte_display = qte_display_packed.instantiate()
	add_child(qte_display)
	
	# add sounds
	shake_sound = AudioStreamPlayer.new()
	shake_sound.stream = load("res://audio/sfx/bush shake 2.wav")
	shake_sound.volume_db = -10
	add_child(shake_sound)

	harvest_sound = AudioStreamPlayer.new()
	harvest_sound.stream = load("res://audio/sfx/Nutrient.wav")
	harvest_sound.volume_db = -7
	add_child(harvest_sound)

	qte_indicator_sound = AudioStreamPlayer.new()
	qte_indicator_sound.stream = load("res://audio/sfx/qte_indicator.wav")
	qte_indicator_sound.volume_db = -7
	add_child(qte_indicator_sound)
	
	qte_failure_sound = AudioStreamPlayer.new()
	qte_failure_sound.stream = load("res://audio/sfx/qte_failure.wav")
	qte_failure_sound.volume_db = -7
	add_child(qte_failure_sound)

	roll_for_dna_strand()

	# signals
	qte_timer.connect("timeout", on_quicktime_timer_timeout)
	start_timer.connect("timeout", on_start_timer_timeout)
	connect("area_entered", on_body_entered)
	connect("area_exited", on_body_exited)
	
	# development
	#shape.disabled = true

func _input(event):
	if dodder and not is_animating and is_harvest_phase:
		if ((event.is_action_pressed("QTE1") and qte_prompt == 1) \
		or (event.is_action_pressed("QTE2") and qte_prompt == 2) \
		or (event.is_action_pressed("QTE3") and qte_prompt == 3)) \
		and not qte_timer.is_stopped():
			qte_success()
		elif (event.is_action_pressed("QTE1") and qte_prompt != 1) \
		or (event.is_action_pressed("QTE2") and qte_prompt != 2) \
		or (event.is_action_pressed("QTE3") and qte_prompt != 3):
			qte_failure()

func show_popup_text():
	popup_text.show()
	popup_text.get_node("AnimationPlayer").play("text_popup")
	
func hide_popup_text():
	popup_text.hide()
	
func show_harvest():
	popup_text.show()
	popup_text.get_node("Label").hide()
	popup_text.get_node("Harvest Label/Label").text = "+{n_yield}".format({n_yield=nutrient_yield})
	popup_text.get_node("Harvest Label").show()
	popup_text.get_node("AnimationPlayer").play("harvest")
	
	await get_tree().create_timer(1).timeout
	popup_text.hide()
	popup_text.get_node("Label").show()
	popup_text.get_node("Harvest Label").hide()

func attach(d : Dodder) -> void:
	# show the shake animation
	animation_player.play("plant-shake/shake")
	shake_sound.play()
	dodder = d
	sprite.animation = "infected"
	await get_tree().create_timer(0.1).timeout
	
	if has_stemrunner:
		begin_stemrunner_phase()
	else:
		begin_harvest_phase()
	
func detach() -> void:
	sprite.modulate = Color(0.5, 0.5, 0.5)
	is_depleted = true
	qte_stop()
	start_timer.stop()
	qte_display.visible = false
	shake_sound.play()
	dodder = null
	animation_player.play("plant-shake/shake")
	await get_tree().create_timer(0.1).timeout
	sprite.animation = "idle"
	
	if get_node_or_null("Stemrunner"):
		get_node("Stemrunner").call_deferred("queue_free")
	if get_node_or_null("Clawgame"):
		get_node("Clawgame").call_deferred("queue_free")

func show_phase_popup(phase_text: String):
	popup_text.get_node("Phase Sign/Panel/Label").text = phase_text
	popup_text.get_node("AnimationPlayer").play("phase_popup")

func begin_stemrunner_phase():
	# show the stemrunner phase popup animation
	show_phase_popup("Incursion Phase")
	is_animating = true
	await get_tree().create_timer(1.8).timeout
	is_animating = false
	
	var stemrunner = load("res://scenes/minigames/stemrunner.tscn")
	var stemrunner_instance: CanvasLayer = stemrunner.instantiate()
	
	add_child(stemrunner_instance)

func stemrunner_win():
	get_node("Stemrunner").call_deferred("queue_free")
	begin_harvest_phase()

func stemrunner_loss():
	get_node("Stemrunner").call_deferred("queue_free")
	depleted_event()

func clawgame_win():
	dodder.get_dna_strand(dna_strand)
	dodder.detach()

func clawgame_loss():
	dodder.detach()

func begin_harvest_phase():
	# show the phase popup animation
	show_phase_popup("Harvest Phase")
	is_animating = true
	await get_tree().create_timer(1.8).timeout
	is_animating = false
	
	qte_display.show()
	start_timer.start()
	is_harvest_phase = true

func begin_theft_phase():
	# end harvest phase
	qte_display.hide()
	start_timer.stop()
	is_harvest_phase = false
	
	# show the phase popup animation
	show_phase_popup("Dna Theft Phase")
	is_animating = true
	await get_tree().create_timer(1.8).timeout
	is_animating = false
	
	var clawgame_packed = load("res://scenes/minigames/clawgame.tscn")
	var clawgame_instance = clawgame_packed.instantiate()
	add_child(clawgame_instance)

func qte_start():
	qte_indicator_sound.play()
	var num = rng.randi_range(0, 2)
	
	var button_sprite: AnimatedSprite2D = null
	if num == 0:
		button_sprite = qte_display.get_node("One/One Button")
		qte_prompt = 1
	elif num == 1:
		button_sprite = qte_display.get_node("Two/Two Button")
		qte_prompt = 2
	else:
		button_sprite = qte_display.get_node("Three/Three Button")
		qte_prompt = 3
	button_sprite.animation = "active"

	qte_timer.start()

func qte_stop():
	qte_timer.stop()
	qte_prompt = null
	
	var one: AnimatedSprite2D = qte_display.get_node("One/One Button")
	one.set_frame(0)
	one.animation = "idle"
	var two: AnimatedSprite2D = qte_display.get_node("Two/Two Button")
	two.set_frame(0)
	two.animation = "idle"
	var three: AnimatedSprite2D = qte_display.get_node("Three/Three Button")
	three.set_frame(0)
	three.animation = "idle"

func qte_success():
	harvest_sound.play()
	dodder.change_nutrients(nutrient_yield)
	qte_stop()
	show_harvest()
	
	nutrient_count -= nutrient_yield
	if nutrient_count <= 0:
		if dna_strand:
			# we begin the clawgame
			begin_theft_phase()
		else:
			depleted_event()

func qte_failure():
	start_timer.stop()
	qte_timer.stop()
	qte_failure_sound.play()
	is_animating = true
	var one: AnimatedSprite2D = qte_display.get_node("One/One Button")
	var two: AnimatedSprite2D = qte_display.get_node("Two/Two Button")
	var three: AnimatedSprite2D = qte_display.get_node("Three/Three Button")
	one.set_frame(0)
	one.animation = "wrong"
	two.set_frame(0)
	two.animation = "wrong"
	three.set_frame(0)
	three.animation = "wrong"
	
	await get_tree().create_timer(1.0).timeout
	is_animating = false
	one.set_frame(0)
	one.animation = "idle"
	two.set_frame(0)
	two.animation = "idle"
	three.set_frame(0)
	three.animation = "idle"
	
	start_timer.start()
	
	# punishment for failure is unrealised yield
	nutrient_count -= nutrient_yield
	if nutrient_count <= 0:
		if dna_strand:
			# we begin the clawgame
			begin_theft_phase()
		else:
			depleted_event()

func on_quicktime_timer_timeout():
	qte_stop()

func on_start_timer_timeout():
	if qte_countdown == null:
		qte_countdown = rng.randi_range(1, 5)
	if dodder != null and qte_timer.is_stopped():
		if qte_countdown <= 0:
			qte_start()
			qte_countdown = rng.randi_range(1, 5)
		else:
			qte_countdown -= 1

func depleted_event():
	dodder.detach()

func on_body_entered(body):
	if body is Dodder:
		show_popup_text()

func on_body_exited(body):
	if body is Dodder:
		hide_popup_text()

## rng, če ima plant dna ali ne
func roll_for_dna_strand():
	var roll = rng.randi_range(1, 1)
	if roll == 1:
		var strand = rng.randi_range(1, 4)
		if strand == 1:
			# double dna
			sprite.modulate = Color.LIME_GREEN
			dna_strand = "double"
		elif strand == 2:
			# better walk
			sprite.modulate = Color.SALMON
			dna_strand = "walk"
		elif strand == 3:
			# stemrunner seeking
			sprite.modulate = Color.CORNFLOWER_BLUE
			dna_strand = "seek"
		else:
			# combo
			sprite.modulate = Color.GOLD
			dna_strand = "combo"
