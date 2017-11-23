extends Node2D

var buildings = preload("res://buildings.tscn").instance()
var guns = preload("res://Guns.tscn")
var armour = preload("res://armour.tscn")
var survivor = preload("res://Allies.tscn").instance()
var enemies = preload("res://Enemies.tscn").instance()
var resource = preload("res://resource.tscn").instance()
var darkness = preload("res://darkness.tscn").instance()

var enemy_reinforce
var faction
var enemy_faction

var map_coords = []

var loaded = false

var party


func reinforce():
	var number= 0
	for spawn in range(enemy_reinforce):
		var zombie = enemies.get_node("Zombie_screamer").duplicate()
		enemy_faction.add_child(zombie)
		if get_node("Area2D/spawns").get_children().size() - 1 < number:
			number = 0
		zombie.set_global_pos(get_node("Area2D/spawns").get_children()[number].get_global_pos())
		number += 1

func cell_randomizer():
	for cells in get_node("base").get_used_cells():
		get_node("base").set_cell(cells.x, cells.y, round(rand_range(0, 1)))
	for cells in get_node("trim").get_used_cells():
		get_node("trim").set_cell(cells.x, cells.y, round(rand_range(0, 1)))
	for cells in get_node("background").get_used_cells():
		get_node("background").set_cell(cells.x, cells.y, round(rand_range(0, 1)))
		
#func night():
#	for cells in get_node("inside_wall_trim").get_used_cells():
#		var coords = get_node("inside_wall_trim").map_to_world(cells)
#		var dark = darkness.get_node("Darkness").duplicate()
#		get_node("night").add_child(dark)
#		dark.set_global_pos(Vector2(coords.x + 10 + get_global_pos().x, coords.y + 10))
#		dark.show()
#	for cells in get_node("inside_wall_colour").get_used_cells():
#		var coords = get_node("inside_wall_colour").map_to_world(cells)
#		var dark = darkness.get_node("Darkness").duplicate()
#		get_node("night").add_child(dark)
#		dark.set_global_pos(Vector2(coords.x + 10 + get_global_pos().x, coords.y + 10))
#		dark.show()
#	for cells in get_node("base").get_used_cells():
#		var coords = get_node("base").map_to_world(cells)
#		var dark = darkness.get_node("Darkness").duplicate()
#		get_node("night").add_child(dark)
#		dark.set_global_pos(Vector2(coords.x + 10 + get_global_pos().x, coords.y + 10))
#		dark.show()