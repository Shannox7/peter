extends "res://Data/Buildings/Barricades.gd"
var name = "Tall Steel Wall"
var cost = 10
var build_time = 5
var size = 1
#func initialize():
#	set_z(-1)
#	level = get_parent().get_parent()
#	faction = get_parent()
#	get_node("KinematicBody2D").set_layer_mask_bit(frontorback, true)
#	faction.defence_list.append(self)
#	get_node("KinematicBody2D").set_layer_mask_bit(faction.sidenumber, true)

func AI_recount(AI):
	AI.walls -= 1
	
func _ready():
	full = true
	total_health = 100
	health = total_health

func builder():
	return builder.get_node("two_tile_y/Build")

func red():
	get_node("body 1").set_modulate(Color(255, 1, 1))
func original_colour():
	get_node("body 1").set_modulate(Color(1, 1, 1))



