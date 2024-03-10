class_name BasicBush

extends Area2D

## Trenutno je to class za bush, s katerim testam shit.
## Kasneje bi želel nek generic plant class.
## Na plants se lahko attacha dodder in potem od njih pobira stvari,
## kot so nutrients in dna (abilities).

var is_colliding = false # morda nepotrebno
@onready var attach_label: Label = get_node("Attach Label") # ui indikator
@onready var sprite: AnimatedSprite2D = get_node("Sprite")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var label_animation_player: AnimationPlayer = get_node("LabelAnimationPlayer")

# plant stats
var plant_name = "The Foobar Plant"
var nutrients = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	attach_label.text = "{plant_name}\nAttach [e]".format({plant_name=plant_name})

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if body is Dodder:
		is_colliding = true
		attach_label.visible = true
		label_animation_player.play("text_popup")
		body.attachable_plant = self


func _on_body_exited(body):
	if body is Dodder:
		is_colliding = false
		attach_label.visible = false
		body.attachable_plant = null

## Predvaja animacijo, ko se dodder attacha gor na plant.
func attach():
	animation_player.play("shake")
	await get_tree().create_timer(0.1).timeout
	sprite.animation = "infected"

func detach():
	animation_player.play("shake")
	await get_tree().create_timer(0.1).timeout
	sprite.animation = "idle"
