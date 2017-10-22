extends Node2D
var faction = preload("res://Faction.tscn").instance()
var game_over = false
#var buildings = preload("res://Buildings.tscn").instance()
var AI = preload("res://AI.tscn").instance()
var buildings = preload("res://buildings.tscn").instance()
var guns = preload("res://Guns.tscn")
var armour = preload("res://armour.tscn")
#var player = preload("res://Peter.tscn").instance()
#var player_1 = player
#var player_2
var objective_list = []
var fact1
var fact2
var fact3

func _ready():
	var AI_2 = AI.duplicate()
	get_node("Timer").connect("timeout", self, "close")
	for children in get_node("dzones").get_children():
		objective_list.append(children.myself)
#	objective_list.front().set_controlled("allies")
#	objective_list.back().set_controlled("enemies")
#	objective_list[1].set_controlled("enemies")
	fact1 = faction.duplicate()
	fact2 = faction.duplicate() 
	
	fact1.side = "allies"
	fact1.enemyside = "enemies"
	fact1.sidenumber = 1
	fact1.enemynumber = 2
	fact1.enemynumberval = 4
	fact1.points = 300
	
	fact2.side = "enemies"
	fact2.enemyside = "allies"
	fact2.sidenumber = 2
	fact2.enemynumber = 1
	fact2.enemynumberval = 2
	fact2.points = 300
	fact2.flipped = true

	
	add_child(fact1)
	add_child(fact2)
	fact2.AI = true
#	fact1.AI = true

#	fact3 = fact2.duplicate()
#	fact3.side = "enemies"
#	fact3.enemyside = "allies"
#	fact3.sidenumber = 2
#	fact3.enemynumber = 1
#	fact3.enemynumberval = 2
#	fact3.points = 50
#	fact3.flipped = true
#	add_child(fact3)
#	fact3.AI = true
	
	AI.build_zone = get_node("dzones/defence_zone2")
	AI_2.build_zone = get_node("dzones/defence_zone")
#	var AI_2 = AI.duplicate()
#	AI_2.build_zone = get_node("dzones/defence_zone1")
	
#enemies
	call_deferred("positioning", fact2, get_node("enemy_defence_1"), get_node("dzones/defence_zone2"), true)
#	call_deferred("positioning", fact3, get_node("enemy_defence_2"), get_node("dzones/defence_zone1"), true)

#allies
	call_deferred("positioning", fact1, get_node("ally_defence"), get_node("dzones/defence_zone"), false)
	
	fact2.call_deferred("add_child", AI)
#	fact1.call_deferred("add_child", AI_2)

#	fact3.call_deferred("add_child", AI_2)
	
#	if player_2 != null:
#		player_2.set_pos(get_node("player_2_spawn").get_pos())
#		fact1.add_child(player_2)

	Global.player.level = self
	Global.player.faction = fact1
	Global.player.set_pos(get_node("player_1_spawn").get_pos())
	Global.player.get_parent().remove_child(Global.player)
	Global.player.combat = true
	fact1.call_deferred("add_child", Global.player)
	
#	
func positioning(faction, node, zone, flipped):
	zone.set_controlled(faction.side)
	for buildings in node.get_children():
		buildings.get_parent().call_deferred("remove_child", buildings)
		buildings.manual_placed = true
		buildings.defence_zone = zone
		buildings.flip(flipped)
		faction.call_deferred("add_child", buildings)
		buildings.call_deferred("positioning")
		buildings.call_deferred("initialize")

func check_win():
	var win = true
	for obj in objective_list:
		if obj.get_ref().side == fact2.side:
			win = false
			break
	if win == true:
		for players in fact1.player_list:
			var lab = get_node("Label").duplicate()
			players.comment("yeeehaw!")
			get_node("Timer").start()
			game_over = true

	else:
		check_lose()
func check_lose():
	var lose = true
	for obj in objective_list:
		if obj.get_ref().side == fact1.side:
			lose = false
			break
	if lose == true:
		for players in fact1.player_list:
			var lab = get_node("Label").duplicate()
			players.comment("fuccccck!")
			get_node("Timer").start()
			game_over = true
func close():
	if not fact1.AI:
		for players in fact1.player_list:
			players.get_parent().remove_child(players)
	if not fact2.AI:
		for players in fact2.player_list:
			players.get_parent().remove_child(players)
	get_node("/root/Global").goto_scene("res://Base.tscn")
	

func points(side, points):
	if side == "allies":
		fact1.points += points
		if not fact1.AI:
			for players in fact1.player_list:
				players.update_hud()
	else:
		fact2.points += points
		if not fact2.AI:
			for players in fact2.player_list:
				players.update_hud()