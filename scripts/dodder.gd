class_name Dodder
extends Area2D

## To je class za dodder, ki se premika naokrog in ni attached na ničemer.
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var step_sound: AudioStreamPlayer = get_node("StepSound")
@onready var map: Map = get_parent()

var nutrients : int = 50
var plant: Plant = null

var state = States.Detached
enum States {
	Attached,
	Detached,
	GameEnd
}

var is_moving = false

var has_double_strand = false
var has_walk_strand = false
var has_seek_strand = false
var has_combo_strand = false

var walk_cost_skipped = false

var combo = 0

# hack, to know when to not display the dodder ui info label
var areacount = 0

var steps = []

var sector_x: int = 2
var sector_y: int = 2

func _ready():
	map.refresh_nutrient_count(nutrients)
	set_enabled_sectors()

func _input(event):
	if event.is_action_pressed("click") and state == States.Detached and not is_moving:
		var p = get_global_mouse_position()
		if p.x < -64 or p.y < -64  or p.x > 576 or p.y > 576:
			pass
		else:
			move_to(p)
			map.move_cam(p)
	match state:
		States.Detached:
			if event.is_action_pressed("attach") and plant and not plant.is_animating:
				if not plant.is_depleted:
					attach()
		States.Attached:
			if event.is_action_pressed("detach") and plant and not plant.is_animating:
				detach()
	
## Fancy movement funkcija. vzame razdaljo med klikom in trenutno pozicijo,
## določi vmesne korake za "animacijo", in se postopoma premakne po teh korakih.
## Vzamemo en korak na vsakih 32 pikslov razdalje.
func move_to(click_pos: Vector2):
	is_moving = true
	var diff = click_pos - position # vektor od dodderja do klika
	var dist = diff.length()
	var step_count = int(dist / 32) # število vmesnih korakov
	
	for i in range(1, step_count+1):
		steps.append(position + diff.normalized()*32*i)
	steps.append(click_pos)
	
	while !steps.is_empty():
		var point = steps.pop_front()
		animation_player.play("shrink")
		await get_tree().create_timer(0.3).timeout # počakamo da se animacija zaključi, preden se premaknemo
		position = point
		find_current_sector()
		set_enabled_sectors()
		if (has_walk_strand and walk_cost_skipped) or not has_walk_strand:
			change_nutrients(-1) # stane 1 nutrient, da se premakneš
			walk_cost_skipped = false
		else:
			walk_cost_skipped = true
		step_sound.play()
		animation_player.play("grow")
		await get_tree().create_timer(0.3).timeout
	is_moving = false

## dodder se attacha na plant. Zbrišemo ta physical dodder entity.
func attach():
	plant.attach(self)
	
	set_colisions_disabled(true)
	
	state = States.Attached
	visible = false
	map.move_cam(plant.global_position)
	map.dodder_attached_event()

func detach():
	plant.detach()
	
	set_colisions_disabled(false)
	
	state = States.Detached
	position = plant.global_position + Vector2(0, 15)
	visible = true
	map.move_cam(position)

func change_nutrients(amount : int) -> void:
	nutrients += amount
	map.refresh_nutrient_count(nutrients)
	
	if nutrients >= 1000:
		win()
	elif nutrients <= 0:
		steps = [] # stops the dodder from moving
		loss()

func set_colisions_disabled(b : bool) -> void:
	$CollisionShape2D.disabled = b

func _on_area_entered(area):
	if area is Plant:
		plant = area
		map.dodder_attachable_event(plant.is_depleted)
	areacount += 1


func _on_area_exited(_area):
	areacount -= 1
	if areacount == 0 and state == States.Detached:
		map.dodder_hide_info_text()
		plant = null

func get_dna_strand(strand: String):
	map.update_dna_strand_ui(strand)
	if strand == "double":
		has_double_strand = true
	elif strand == "walk":
		has_walk_strand = true
	elif strand == "seek":
		has_seek_strand = true
	elif strand == "combo":
		has_combo_strand = true

func win():
	var win_packed = load("res://scenes/win_screen.tscn")
	var win_instance = win_packed.instantiate()
	
	state = States.GameEnd
	hide_all_ui()
	
	add_child(win_instance)

func loss():
	var loss_packed = load("res://scenes/loss_screen.tscn")
	var loss_instance = loss_packed.instantiate()
	
	state = States.GameEnd
	hide_all_ui()
	
	add_child(loss_instance)

func hide_all_ui():
	if plant:
		plant.qte_display.hide()
		plant.qte_timer.stop()
		plant.start_timer.stop()
		
	map.dodder_ui.hide()

func set_enabled_sectors():
	var feasible_x = [sector_x - 2, sector_x - 1, sector_x, sector_x + 1, sector_x + 2]
	var feasible_y = [sector_y - 1, sector_y, sector_y + 1]
	for sector in map.sectors:
		if (sector.x in feasible_x) and (sector.y in feasible_y):
			sector.show()
		else:
			sector.hide()

func find_current_sector():
	sector_x = int(floor((position.x + 64) / 128))
	sector_y = int(floor((position.y + 64) / 128))
