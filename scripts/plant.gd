class_name Plant
extends Node

var plant_name : String
var nutrients : int

func initialize_stats(stats : PlantStats) -> void:
	plant_name = stats.name
	nutrients = stats.nutrients
	
func attach(d : Dodder) -> void:
	pass
	
func detach() -> void:
	pass
