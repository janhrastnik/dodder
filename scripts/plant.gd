class_name Plant
extends Node

@export var stats : PlantStats
var plant_name : String
var nutrients : int

func _ready() -> void:
	plant_name = stats.name
	nutrients = stats.nutrients
	
func attach(d : Dodder) -> void:
	pass
	
func detach() -> void:
	pass
