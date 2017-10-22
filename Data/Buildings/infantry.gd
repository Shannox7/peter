extends "res://Data/Buildings/spawn_buildings.gd"
var name = "Barracks"
var cost = 25
var build_time = 10
var size = 4
var Gun
func AI_recount(AI):
	AI.infantry -= 1
	
func builder():
	return builder.get_node("four_tile_x/Build")

func init():
	level = get_parent().get_parent()
	soldier = true
	spawn_time = 2
	total_spawn_time = 2
	object = preload("res://Allies.tscn").instance().get_node("Infantry")
	Gun = level.guns.instance().get_node("Soldier_guns/AK47")
	pass
