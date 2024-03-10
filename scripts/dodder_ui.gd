extends CanvasLayer

@onready var hivemind: HivemindSingleton = get_node("/root/Hivemind") # global gamedata
@onready var detach_label: Label = get_node("Detach Label")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_detach_label():
	detach_label.visible = true
	
func hide_detach_label():
	detach_label.visible = false
