class_name Plant
extends Area2D

## The plant node.

# plant stats
var dodder : Dodder = null
@export var stats : PlantStats
var plant_name : String
var nutrients : int

# needed nodes
var popup_text: Node2D = null
var qte_timer: Timer = null

func _ready() -> void:
	plant_name = stats.name
	nutrients = stats.nutrients
	
	# construct subnodes
	var popup_text_packed = load("res://scenes/ui/popup_text.tscn")
	popup_text = popup_text_packed.instantiate()
	popup_text.get_node("Label").text = stats.name
	add_child(popup_text)
	
	qte_timer = Timer.new()
	qte_timer.one_shot = true
	qte_timer.name = "QTE Timer"
	add_child(popup_text)
	
func show_popup_text():
	popup_text.show()
	popup_text.get_node("AnimationPlayer").play("text_popup")
	
func hide_popup_text():
	popup_text.hide()
	
func show_harvest():
	popup_text.show()
	popup_text.get_node("Label").hide()
	popup_text.get_node("Harvest Label").show()
	popup_text.get_node("AnimationPlayer").play("harvest")
	
	await get_tree().create_timer(1).timeout
	popup_text.hide()
	popup_text.get_node("Label").show()
	popup_text.get_node("Harvest Label").hide()

func attach(d : Dodder) -> void:
	pass
	
func detach() -> void:
	pass
