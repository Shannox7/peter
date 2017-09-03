extends "res://Data/Buildings/defence.gd"
var name = "Foxhole"
var cost = 5
var build_time = 5
var size = 2

func AI_recount(AI):
	AI.bunkers -= 1
	
func ready():
	total_health = 100
	operators_size = 1
	health = total_health
	
func builder():
	return builder.get_node("four_tile_square_lower/Build")

func place(defender):
	defender.set_pos(get_node("body/defend_pos").get_global_pos())

func red():
	get_node("body 1").set_modulate(Color(255, 0, 0))
func original_colour():
	get_node("body 1").set_modulate(Color(1, 1, 1))
