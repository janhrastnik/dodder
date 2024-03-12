extends CanvasLayer

@onready var grid: GridContainer = get_node("GridContainer")

# Called when the node enters the scene tree for the first time.
func _ready():
	init_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init_grid():
	var texture: Texture2D = load("res://textures/stemrunner/test64x64.png")
	for i in range(16):
		var tile = TextureRect.new()
		tile.texture = texture
		grid.add_child(tile)
