extends "res://Data/Buildings/spawn_buildings.gd"
var name = "Helicopter Pad"
var cost = 50
var build_time = 2
var size = 6

func AI_recount(AI):
	AI.HQ -= 1
	
func builder():
	return builder.get_node("six_tile_x/Build")
	
func init():
	spawn_time = 0
	total_spawn_time = 10
	spawn_limit = 1
	limited = true
	object = preload("res://Allies.tscn").instance().get_node("Helicopter")
	pass
