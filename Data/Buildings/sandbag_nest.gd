extends "res://Data/Buildings/defence.gd"
var name = "Sandbag Nest"
var cost = 5
var build_time = 5
var size = 3
func _ready():
	total_health = 100
	health = total_health
	pass


func builder():
	return builder.get_node("three_tile_x//Build")

func place(defender):
	defender.set_pos(get_node("defend_pos").get_global_pos())
	
func red():
	get_node("body").set_modulate(Color(255, 0, 0))
	get_node("body 2").set_modulate(Color(255, 0, 0))
	get_node("body 3").set_modulate(Color(255, 0, 0))
func original_colour():
	get_node("body").set_modulate(Color(1, 1, 1))
	get_node("body 2").set_modulate(Color(1, 1, 1))
	get_node("body 3").set_modulate(Color(1, 1, 1))

		
