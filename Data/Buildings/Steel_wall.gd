extends "res://Data/Buildings/Barricades.gd"
var name = "Steel Wall"
var cost = 5
var build_time = 5
var size = 1
func _ready():
	full = true
	health = total_health
	pass
	
func builder():
	return builder.get_node("one_tile/Build")
	
func red():
	get_node("body 1").set_modulate(Color(255, 1, 1))
func original_colour():
	get_node("body 1").set_modulate(Color(1, 1, 1))