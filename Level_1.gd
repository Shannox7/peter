extends Node2D
var faction = preload("res://Faction.tscn").instance()
#var buildings = preload("res://Buildings.tscn").instance()
var AI = preload("res://AI.tscn").instance()
var objective_list = []
var fact1
var fact2
func _ready():
	objective_list = get_node("dzones").get_children()
#	objective_list.front().set_controlled("allies")
#	objective_list.back().set_controlled("enemies")
#	objective_list[1].set_controlled("enemies")
	fact1 = faction.duplicate()
	fact2 = faction.duplicate() 
	
	fact1.side = "allies"
	fact1.enemyside = "enemies"
	fact1.sidenumber = 1
	fact1.enemynumber = 2
	fact1.points = 50
	
	fact2.side = "enemies"
	fact1.enemyside = "allies"
	fact1.sidenumber = 2
	fact1.enemynumber = 1
	fact2.points = 300
	
	add_child(fact2)
	fact2.add_child(AI)
	fact2.AI = true
	
	add_child(fact1)
	
	if get_parent().player_2 != null:
		get_parent().player_2.set_pos(get_node("player_2_spawn").get_pos())
		fact1.add_child(get_parent().player_2)
	get_parent().player_1.set_pos(get_node("player_1_spawn").get_pos())
	fact1.add_child(get_parent().player_1)

#enemies
	positioning(fact2, get_node("enemy_defence_1"), get_node("dzones/defence_zone2"))
#	positioning(fact2, get_node("enemy_defence_2"), get_node("dzones/defence_zone1"))

#allies
	positioning(fact1, get_node("ally_defence"), get_node("dzones/defence_zone"))
	
func positioning(faction, node, zone):
	zone.set_controlled(faction.side)
	for buildings in node.get_children():
		buildings.get_parent().remove_child(buildings)
		faction.add_child(buildings)
		buildings.defence_zone = zone
		buildings.positioning()
		buildings.activate()
		
#func add_ally_HQ():
#	var HQ = buildings.get_node("Spawn_buildings/HQ").duplicate()
#	HQ.set_pos(objective_list.front().positions[0].get_global_pos())
#	objective_list.front().positions[2].background = true
#	objective_list.front().positions[1].background = true
#	objective_list.front().positions[0].background = true
#	fact1.add_child(HQ)
#	HQ.activate()
	
func points(side, points):
	if side == "allies":
		fact1.points += points
		for players in fact1.player_list:
			players.update_hud()
	else:
		fact2.points += points
		if not fact2.AI:
			for players in fact2.player_list:
				players.update_hud()