extends "res://Data/Buildings/Barricades.gd"
var name = "Tall Steel Wall"
var cost = 10
var build_time = 5
var size = 1
func _ready():
	full = true
	total_health = 100
	health = total_health

func builder():
	return builder.get_node("two_tile_y/Build")

func red():
	get_node("body").set_modulate(Color(255, 1, 1))
func original_colour():
	get_node("body").set_modulate(Color(1, 1, 1))



