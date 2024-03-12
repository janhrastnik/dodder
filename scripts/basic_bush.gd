class_name BasicBush
extends Plant

## Trenutno je to class za bush, s katerim testam shit.
## Kasneje bi želel nek generic plant class.
## Na plants se lahko attacha dodder in potem od njih pobira stvari,
## kot so nutrients in dna (abilities).

# plant stats
var dodder : Dodder = null

@onready var attach_label: Label = get_node("Attach Label") # ui indikator
@onready var sprite: AnimatedSprite2D = get_node("Sprite")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var label_animation_player: AnimationPlayer = get_node("LabelAnimationPlayer")
@onready var quicktime_timer : Timer = get_node("QuicktimeTimer")
@onready var quicktime_start_timer : Timer = get_node("QuicktimeStartTimer")
@onready var qte_display : HBoxContainer = get_node("QTE Container")
@onready var harvest_label: HBoxContainer = get_node("Harvest Label")
@onready var shake_sound: AudioStreamPlayer = get_node("ShakeSound")
@onready var harvest_sound: AudioStreamPlayer = get_node("HarvestSound")
@onready var qte_indicator_sound: AudioStreamPlayer = get_node("QTEindicatorSound")

# qte številka ki jo player mora pritisnit
var qte_prompt = null

# ko reachamo 0, se začne qte
var qte_countdown = null

var rng = RandomNumberGenerator.new()

func _input(event):
	if ((event.is_action_pressed("QTE1") and qte_prompt == 1) \
	or (event.is_action_pressed("QTE2") and qte_prompt == 2) \
	or (event.is_action_pressed("QTE3") and qte_prompt == 3)) \
	and not quicktime_timer.is_stopped():
		qte_success()

func qte_success():
	harvest_sound.play()
	dodder.change_nutrients(1)
	qte_stop()
	show_harvest_label()

func qte_start():
	qte_indicator_sound.play()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var num = rng.randi_range(0, 2)
	
	var sprite: AnimatedSprite2D = null
	if num == 0:
		sprite = qte_display.get_node("One/One Button")
		qte_prompt = 1
	elif num == 1:
		sprite = qte_display.get_node("Two/Two Button")
		qte_prompt = 2
	else:
		sprite = qte_display.get_node("Three/Three Button")
		qte_prompt = 3
	sprite.animation = "active"

	quicktime_timer.start()

func qte_stop():
	quicktime_timer.stop()
	qte_prompt = null
	print("stopped!")
	
	var one: AnimatedSprite2D = qte_display.get_node("One/One Button")
	one.set_frame(0)
	one.animation = "idle"
	var two: AnimatedSprite2D = qte_display.get_node("Two/Two Button")
	two.set_frame(0)
	two.animation = "idle"
	var three: AnimatedSprite2D = qte_display.get_node("Three/Three Button")
	three.set_frame(0)
	three.animation = "idle"

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	attach_label.text = "{plant_name}\nAttach [e]".format({plant_name=plant_name})
	rng.randomize()

func _on_body_entered(body):
	if body is Dodder:
		attach_label.visible = true
		label_animation_player.play("text_popup")

func _on_body_exited(body):
	if body is Dodder:
		attach_label.visible = false

## Predvaja animacijo, ko se dodder attacha gor na plant.
func attach(d : Dodder):
	dodder = d
	qte_display.visible = true
	quicktime_start_timer.start()
	
	animation_player.play("shake")
	shake_sound.play()
	await get_tree().create_timer(0.1).timeout
	sprite.animation = "infected"

func detach():
	qte_stop() # If in qte
	quicktime_start_timer.stop()
	qte_display.visible = false
	
	animation_player.play("shake")
	shake_sound.play()
	await get_tree().create_timer(0.1).timeout
	sprite.animation = "idle"

func _on_quicktime_timer_timeout():
	qte_stop()

func _on_quicktime_start_timer_timeout():
	if qte_countdown == null:
		qte_countdown = rng.randi_range(1, 5)
	if dodder != null and quicktime_timer.is_stopped():
		if qte_countdown <= 0:
			qte_start()
			qte_countdown = rng.randi_range(1, 5)
		else:
			qte_countdown -= 1

func show_harvest_label():
	harvest_label.visible = true
	label_animation_player.play("harvest_popup")
	await get_tree().create_timer(0.5).timeout
	harvest_label.visible = false
