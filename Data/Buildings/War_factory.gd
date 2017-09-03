extends "res://Data/Buildings/spawn_buildings.gd"
var name = "War Factory"
var cost = 50
var build_time = 10
var size = 6

func AI_recount(AI):
	AI.HQ -= 1
	
func builder():
	return builder.get_node("three_tile_x/Build")
	
func _ready():
	spawn_time = 0
	total_spawn_time = 10
	spawn_limit = 1
	limited = true
	object = preload("res://Allies.tscn").instance().get_node("Tank")
	pass
