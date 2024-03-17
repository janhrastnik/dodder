class_name Stemrunner

extends CanvasLayer

@onready var grid: GridContainer = get_node("GridContainer")
@onready var move_sound: AudioStreamPlayer = get_node("MoveSound")
@onready var win_sound: AudioStreamPlayer = get_node("WinSound")
@onready var loss_sound: AudioStreamPlayer = get_node("LossSound")
@onready var timer: Timer = get_node("Timer")
@onready var timer_label: Label = get_node("Timer Panel/Timer Label") 

enum Direction {
	Up,
	Down,
	Left,
	Right
}

var head_position = Vector2(0, 2)
var direction = Direction.Right

var visited = []

var previous_tile: TextureRect = null

var win_position: Vector2 = Vector2(0, 0)

var win_condition = false

var loss_condition = false

var has_seek_strand = false

# textures
var dodder_head_left = load("res://textures/stemrunner/headleft.png")
var dodder_head_right = load("res://textures/stemrunner/headright.png")
var dodder_head_up = load("res://textures/stemrunner/headup.png")
var dodder_head_down = load("res://textures/stemrunner/headdown.png")

var angle_left_down = load("res://textures/stemrunner/angle-left-down.png")
var angle_left_up = load("res://textures/stemrunner/angle-left-up.png")
var angle_right_down = load("res://textures/stemrunner/angle-right-down.png")
var angle_right_up = load("res://textures/stemrunner/angle-right-up.png")

var pipe_h = load("res://textures/stemrunner/pipe-h.png")
var pipe_v = load("res://textures/stemrunner/pipe-v.png")

var win_left = load("res://textures/stemrunner/winleft.png")
var win_right = load("res://textures/stemrunner/winright.png")
var win_up = load("res://textures/stemrunner/winup.png")
var win_down = load("res://textures/stemrunner/windown.png")

var rng = RandomNumberGenerator.new()

var diff = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	init_grid()
	rng.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer_update(delta)

func _input(event):
	if not win_condition and not loss_condition:
		if event.is_action_pressed("up") and direction != Direction.Down:
			if head_position.y > 0 and not Vector2(head_position.x, head_position.y-1) in visited:
				head_position.y -= 1
				change_grid(Direction.Up)
		elif event.is_action_pressed("down") and direction != Direction.Up:
			if head_position.y < 4 and not Vector2(head_position.x, head_position.y+1) in visited:
				head_position.y += 1
				change_grid(Direction.Down)
		elif event.is_action_pressed("left") and direction != Direction.Right:
			if head_position.x > 0 and not Vector2(head_position.x-1, head_position.y) in visited:
				head_position.x -= 1
				change_grid(Direction.Left)
		elif event.is_action_pressed("right") and direction != Direction.Left:
			if head_position.x < 4 and not Vector2(head_position.x+1, head_position.y) in visited:
				head_position.x += 1
				change_grid(Direction.Right)

func init_grid():
	var base_texture: Texture2D = load("res://textures/stemrunner/hidden.png")
	var marked_texture: Texture2D = load("res://textures/stemrunner/marked.png")

	# determine winning tile by rng
	#win_tile = get_random_tile()
	win_position = get_random_tile()
	while win_position == Vector2(0,2):
		win_position = get_random_tile()
	#win_position = Vector2(2,2) # for development
	
	for i in range(25):
		var tile = TextureRect.new()
		if Vector2(i%5,floor(i/5)) == win_position and has_seek_strand == true:
			tile.texture = marked_texture
		else:
			tile.texture = base_texture
		tile.name = "{x},{y}".format({x=i%5,y=floor(i/5)})
		grid.add_child(tile)

	var current_tile: TextureRect = grid.get_node("0,2")
	previous_tile = current_tile
	current_tile.texture = dodder_head_left
	visited.append(head_position)
	
func change_grid(move_direction: Direction):
	move_sound.play()
	var current_tile: TextureRect = grid.get_node("{x},{y}".format({x=head_position.x,y=head_position.y}))
	if move_direction == Direction.Up:
		if head_position == win_position:
			current_tile.texture = win_up
			win_condition = true
		else:
			current_tile.texture = dodder_head_down
		if direction == Direction.Right:
			previous_tile.texture = angle_left_up
		elif direction == Direction.Left:
			previous_tile.texture = angle_right_up
		else:
			previous_tile.texture = pipe_v
	elif move_direction == Direction.Down:
		if head_position == win_position:
			current_tile.texture = win_down
			win_condition = true
		else:
			current_tile.texture = dodder_head_up
		if direction == Direction.Right:
			previous_tile.texture = angle_left_down
		elif direction == Direction.Left:
			previous_tile.texture = angle_right_down
		else:
			previous_tile.texture = pipe_v
	elif move_direction == Direction.Right:
		if head_position == win_position:
			current_tile.texture = win_left
			win_condition = true
		else:
			current_tile.texture = dodder_head_left
		if direction == Direction.Up:
			previous_tile.texture = angle_right_down
		elif direction == Direction.Down:
			previous_tile.texture = angle_right_up
		else:
			previous_tile.texture = pipe_h
	else:
		if head_position == win_position:
			current_tile.texture = win_right
			win_condition = true
		else:
			current_tile.texture = dodder_head_right
		if direction == Direction.Up:
			previous_tile.texture = angle_left_down
		elif direction == Direction.Down:
			previous_tile.texture = angle_left_up
		else:
			previous_tile.texture = pipe_h
	direction = move_direction
	previous_tile = current_tile
	visited.append(head_position)
	if win_condition:
		win()

func get_random_tile() -> Vector2:
	var x = rng.randi_range(0, 4)
	var y = rng.randi_range(0, 4)
	return Vector2(x, y)

func win():
	win_sound.play()
	await get_tree().create_timer(1.0).timeout
	get_parent().stemrunner_win()

func loss():
	loss_sound.play()
	loss_condition = true
	await get_tree().create_timer(1.0).timeout
	get_parent().stemrunner_loss()

func _on_timer_timeout():
	loss()

func timer_update(delta: float):
	if win_condition:
		timer_label.text = "Found the nutrient storage!"
	elif loss_condition:
		timer_label.text = "Time's out!"
	else:
		diff += delta
		if diff > 0.5:
			timer_label.text = str(round(timer.time_left)) + " seconds left!"
			diff = 0
