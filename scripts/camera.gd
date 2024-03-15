extends Camera2D

var t = 0.0
var start = null
var end = null
var is_moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	position_smoothing_enabled = true

func slide(to: Vector2):
	await get_tree().create_timer(0.2).timeout
	var quotient = (to - position).length()
	position_smoothing_speed = quotient / 20
	set_position(to)
