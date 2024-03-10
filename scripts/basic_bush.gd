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
@onready var quicktime_label : Label = get_node("QTE")

func _input(event):
	if event.is_action_pressed("QTE1") and not quicktime_timer.is_stopped():
		dodder.gain_nutrients(1)
		qte_stop()

func qte_start():
	quicktime_label.show()
	quicktime_timer.start()

func qte_stop():
	quicktime_label.hide()
	quicktime_timer.stop()

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	attach_label.text = "{plant_name}\nAttach [e]".format({plant_name=plant_name})

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
	quicktime_start_timer.start()
	
	animation_player.play("shake")
	await get_tree().create_timer(0.1).timeout
	sprite.animation = "infected"

func detach():
	quicktime_start_timer.stop()
	
	animation_player.play("shake")
	await get_tree().create_timer(0.1).timeout
	sprite.animation = "idle"

func _on_quicktime_timer_timeout():
	quicktime_label.hide()

func _on_quicktime_start_timer_timeout():
	if dodder != null and quicktime_timer.is_stopped():
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var num = rng.randi_range(0, 2)
		
		if num == 0:
			qte_start()
