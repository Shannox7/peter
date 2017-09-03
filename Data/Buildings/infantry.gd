extends "res://Data/Buildings/spawn_buildings.gd"
var guns = preload("res://Guns.tscn")
var name = "Barracks"
var cost = 25
var build_time = 10
var size = 4
var Gun
func AI_recount(AI):
	AI.infantry -= 1
	
func builder():
	return builder.get_node("four_tile_x/Build")
	
func _ready():
	spawn_time = 0
	total_spawn_time = 10
	object = preload("res://Allies.tscn").instance().get_node("Infantry")
	Gun = guns.instance().get_node("Soldier_guns/AK47")
	pass
