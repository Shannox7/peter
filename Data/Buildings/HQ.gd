extends "res://Data/Buildings/spawn_buildings.gd"
var name = "HQ"
var cost = 25
var build_time = 10
var size = 3

func builder():
	return builder.get_node("Two_tile_x/Build")
	
func _ready():
	spawn_time = 10
	total_spawn_time = 10
	spawn_limit = 1
	limited = true
	object = preload("res://Allies.tscn").instance().get_node("Engineer")
	pass
