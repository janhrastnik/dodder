class_name Plant
extends Area2D

## The plant node.

# plant stats
var dodder : Dodder = null
@export var stats : PlantStats
var plant_name : String
var nutrients : int

# needed nodes
var popup_text: Node2D = null
var qte_timer: Timer = null
var start_timer: Timer = null
var qte_display : HBoxContainer = null

var shake_sound: AudioStreamPlayer = null
var harvest_sound: AudioStreamPlayer = null
var qte_indicator_sound: AudioStreamPlayer = null

# qte številka ki jo player mora pritisnit
var qte_prompt = null

# ko reachamo 0, se začne qte
var qte_countdown = null

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	plant_name = stats.name
	nutrients = stats.nutrients
	
	rng.randomize()
	
	# construct subnodes
	var popup_text_packed = load("res://scenes/ui/popup_text.tscn")
	popup_text = popup_text_packed.instantiate()
	popup_text.get_node("Label").text = stats.name
	add_child(popup_text)
	
	qte_timer = Timer.new()
	qte_timer.one_shot = true
	qte_timer.name = "QTE Timer"
	#qte_timer.connect("timeout", qte_timer_timeout)
	add_child(qte_timer)

	start_timer = Timer.new()
	start_timer.name = "Start Timer"
	#qte_timer.connect("timeout", qte_timer_timeout)
	add_child(start_timer)
	
	var qte_display_packed = load("res://scenes/plants/qte_container.tscn")
	qte_display = qte_display_packed.instantiate()
	add_child(qte_display)
	
	# add sounds
	shake_sound = AudioStreamPlayer.new()
	shake_sound.stream = load("res://audio/sfx/Bush Shake 2.wav")
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
	
	qte_timer.connect("timeout", on_quicktime_timer_timeout)
	start_timer.connect("timeout", on_start_timer_timeout)

func _input(event):
	if ((event.is_action_pressed("QTE1") and qte_prompt == 1) \
	or (event.is_action_pressed("QTE2") and qte_prompt == 2) \
	or (event.is_action_pressed("QTE3") and qte_prompt == 3)) \
	and not qte_timer.is_stopped():
		qte_success()

func show_popup_text():
	popup_text.show()
	popup_text.get_node("AnimationPlayer").play("text_popup")
	
func hide_popup_text():
	popup_text.hide()
	
func show_harvest():
	popup_text.show()
	popup_text.get_node("Label").hide()
	popup_text.get_node("Harvest Label").show()
	popup_text.get_node("AnimationPlayer").play("harvest")
	
	await get_tree().create_timer(1).timeout
	popup_text.hide()
	popup_text.get_node("Label").show()
	popup_text.get_node("Harvest Label").hide()

func attach(d : Dodder) -> void:
	dodder = d
	qte_display.visible = true
	start_timer.start()
	shake_sound.play()
	
func detach() -> void:
	qte_stop()
	start_timer.stop()
	qte_display.visible = false
	shake_sound.play()

func qte_timer_timeout():
	pass

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
	dodder.change_nutrients(1)
	qte_stop()
	show_harvest()

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
