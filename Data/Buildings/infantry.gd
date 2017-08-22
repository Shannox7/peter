extends "res://Data/Buildings/spawn_buildings.gd"
var name = "Barracks"
var cost = 25
var build_time = 10
var size = 4
func builder():
	return builder.get_node("four_tile_x/Build")
	
func _ready():
	spawn_time = 10
	total_spawn_time = 10
	object = preload("res://Allies.tscn").instance().get_node("Infantry")
	pass
