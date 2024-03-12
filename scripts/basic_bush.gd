class_name BasicBush
extends Plant

## Trenutno je to class za bush, s katerim testam shit.
## Kasneje bi želel nek generic plant class.
## Na plants se lahko attacha dodder in potem od njih pobira stvari,
## kot so nutrients in dna (abilities).

@onready var sprite: AnimatedSprite2D = get_node("Sprite")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

func _on_body_entered(body):
	if body is Dodder:
		show_popup_text()

func _on_body_exited(body):
	if body is Dodder:
		hide_popup_text()
		pass

## Predvaja animacijo, ko se dodder attacha gor na plant.
func attach(d : Dodder):
	super(d)
	
	animation_player.play("shake")
	await get_tree().create_timer(0.1).timeout
	sprite.animation = "infected"

func detach():
	super()
	
	animation_player.play("shake")
	await get_tree().create_timer(0.1).timeout
	sprite.animation = "idle"
