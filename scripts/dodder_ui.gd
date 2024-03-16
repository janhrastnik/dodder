extends CanvasLayer

@onready var hivemind: HivemindSingleton = get_node("/root/Hivemind") # global gamedata
@onready var info_label: Label = get_node("Info Label")
@onready var dna_descriptor: Panel = get_node("DNA Descriptor")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func attached_event():
	info_label.visible = true
	info_label.text = "Press spacebar to detach"

func hide_info_text():
	info_label.visible = false
	
func attachable_event(is_depleted: bool):
	info_label.visible = true
	if is_depleted:
		info_label.text = "Depleted!"
	else:
		info_label.text = "Press e to attach"

func refresh_nutrient_count(nutrients: int):
	get_node("Nutrients Panel/Nutrients Container/Nutrients Label").text = "Nutrients: {count}".format({count=nutrients})

func show_dna_strand(strand: String):
	if strand == "double":
		get_node("DNA Panel/DNA Container/DNA Strands Container/Green").modulate = Color(1, 1, 1)
	elif strand == "walk":
		get_node("DNA Panel/DNA Container/DNA Strands Container/Red").modulate = Color(1, 1, 1)
	elif strand == "seek":
		get_node("DNA Panel/DNA Container/DNA Strands Container/Blue").modulate = Color(1, 1, 1)
	elif strand == "combo":
		get_node("DNA Panel/DNA Container/DNA Strands Container/Yellow").modulate = Color(1, 1, 1)

func _on_green_mouse_entered():
	dna_descriptor.show()
	dna_descriptor.position = get_viewport().get_mouse_position()
	dna_descriptor.get_node("Label").text = "Doubles the amount of nutrients gained from harvesting plants."
	dna_descriptor.position.x -= 400.0

func _on_green_mouse_exited():
	dna_descriptor.hide()

func _on_red_mouse_entered():
	dna_descriptor.show()
	dna_descriptor.position = get_viewport().get_mouse_position()
	dna_descriptor.get_node("Label").text = "Moving around costs half less nutrients."
	dna_descriptor.position.x -= 400.0

func _on_red_mouse_exited():
	dna_descriptor.hide()

func _on_blue_mouse_entered():
	dna_descriptor.show()
	dna_descriptor.position = get_viewport().get_mouse_position()
	dna_descriptor.get_node("Label").text = "Marks the spot of the nutrient storage in the incursion phase."
	dna_descriptor.position.x -= 400.0

func _on_blue_mouse_exited():
	dna_descriptor.hide()

func _on_yellow_mouse_entered():
	dna_descriptor.show()
	dna_descriptor.position = get_viewport().get_mouse_position()
	dna_descriptor.get_node("Label").text = "Consecutive successful harvests give more nutrients."
	dna_descriptor.position.x -= 400.0

func _on_yellow_mouse_exited():
	dna_descriptor.hide()
