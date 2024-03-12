extends CanvasLayer

@onready var hivemind: HivemindSingleton = get_node("/root/Hivemind") # global gamedata
@onready var info_label: Label = get_node("Info Label")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func attached_event():
	print("here")
	info_label.visible = true
	info_label.text = "Press spacebar to detach"

func hide_info_text():
	info_label.visible = false
	
func attachable_event():
	info_label.visible = true
	info_label.text = "Press e to attach"	

func refresh_nutrient_count(nutrients: int):
	get_node("Panel/VBoxContainer/Label").text = "Nutrients: {count}".format({count=nutrients})
