extends "res://Data/Buildings/spawn_buildings.gd"
var name = "HQ"
var cost = 25
var build_time = 10
var size = 3

func AI_recount(AI):
	AI.HQ -= 1
	
func builder():
	return builder.get_node("three_tile_x/Build")
	
func init():
	spawn_time = 0
	total_spawn_time = 10
	spawn_limit = 1
	limited = true
	health = total_health
	object = preload("res://Allies.tscn").instance().get_node("Engineer")
	pass
