extends CanvasLayer

@onready var hivemind: HivemindSingleton = get_node("/root/Hivemind") # global gamedata
@onready var detach_label: Label = get_node("Detach Label")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func attached_event():
	detach_label.visible = true

func detached_event():
	detach_label.visible = false

func refresh_nutrient_count(nutrients: int):
	get_node("Panel/VBoxContainer/Label").text = "Nutrients: {count}".format({count=nutrients})
