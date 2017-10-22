extends Node2D
var faction = preload("res://Faction.tscn").instance()
var game_over = false
#var buildings = preload("res://Buildings.tscn").instance()
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

var wave = 1

var attacking_land
var defending_land

var timer = 20
var max_timer = 20
func _ready():
	get_node("Timer").connect("timeout", self, "close")
	for zones in get_node("dzones").get_children():
		zones.init()
		objective_list.append(zones.myself)


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
	
	level_start()
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
	
#	AI.
#	AI_2.build_zone = get_node("dzones/defence_zone")
#	var AI_2 = AI.duplicate()
#	AI_2.build_zone = get_node("dzones/defence_zone1")
	
#enemies
#
#	fact2.call_deferred("add_child", AI)
#	fact1.call_deferred("add_child", AI_2)

#	fact3.call_deferred("add_child", AI_2)
	
#	if player_2 != null:
#		player_2.set_pos(get_node("player_2_spawn").get_pos())
#		fact1.add_child(player_2)

#	Global.player.level = self
#	Global.player.faction = fact1
#	Global.player.set_pos(get_node("player_1_spawn").get_pos())
#	Global.player.get_parent().remove_child(Global.player)
#	Global.player.combat = true
#	fact1.call_deferred("add_child", Global.player)

#func start(faction):
#	for defences in faction.defence_list:
#		defences.get_ref().set_fixed_process(false)
#		print(defences.get_ref().get_name())
#	print("start!")
#	if wave == 1:
#		faction.total_soldiers_remaining = faction.max_soldiers
#		if faction.max_soldiers/5 > 0:
#			faction.wave_force = floor(faction.max_soldiers/5)
#	#		if fact1.max_soldiers % 5:
#			faction.wave_force_remainder = faction.max_soldiers % 5
#		else:
#			faction.wave_force_remainder = faction.max_soldiers
#		
#		
#	
#	if faction.wave_force_remainder > 0:
#		faction.wave_force += 1
#		faction.wave_force_remainder -= 1
#	faction.soldiers_remaining = faction.wave_force
#	
#	print(faction.wave_force)
#	print (faction.wave_force_remainder) 
#	
#	faction.soldiers = 0
#	
#	build()
#	
#func build():
#	set_fixed_process(true)
#	print("build!")
#	pass
#
#func _fixed_process(delta):
#	timer -= delta
#	if timer <= 0:
#		timer = max_timer
#		combat(fact1)
#		combat(fact2)
#		set_fixed_process(false)
#
#func combat(faction):
#	for defences in faction.defence_list:
#		defences.get_ref().set_fixed_process(true)
#	pass
#
#func choice():
#	pass
#
#func wave_complete():
#	print("end of wave " + str(wave))
#	check_win()
#	wave += 1
#	start(fact1)
#	start(fact2)
#	pass

#func battle_set_up(attackers, defenders, attacker_force):
#	attacking_land = attackers
#	defending_land = defenders
#	var defence = defenders.get_node("defence_zone").duplicate()
#	get_node("dzones").add_child(defence)
#	defence.set_global_pos(get_node("defence").get_global_pos())
#	print(defence.get_node("buildings/infantry").get_pos())
#	fact1.AI = attackers.AI
#	fact2.AI = defenders.AI
#	for attacker in attackers.players:
#		if not attackers.AI:
#			set_up(attacker, fact1, false)
#		else:
#			attacker.build_zone = get_node("dzones").get_children().front()
#		fact1.call_deferred("add_child", attacker)
#	for defender in defenders.players:
#		if not defenders.AI:
#			set_up(defender, fact2, true)
#		else:
#			defender.build_zone = get_node("dzones").get_children().back()
#		fact2.call_deferred("add_child", defender)
#	
#	fact1.max_soldiers = attacker_force
#	fact2.max_soldiers = defenders.infantry
#	
#	for zones in get_node("dzones").get_children():
#		zones.init()
#		objective_list.append(zones.myself)
#		
#	call_deferred("positioning", fact1, get_node("dzones").get_children().front(), false)
#	call_deferred("positioning", fact2,  get_node("dzones").get_children().back(), true)
#	
#	start(fact1)
#	start(fact2)

func level_start():
	var korea_AI = Global.AI.duplicate()
	fact1.player_list.append(Global.player)
	set_up(Global.player, fact1, false)
	fact1.call_deferred("add_child", Global.player)
	
	fact2.AI = true
	korea_AI.build_zone = get_node("dzones").get_children().back()
	fact2.call_deferred("add_child", korea_AI)
	
	call_deferred("positioning", fact1, get_node("dzones").get_children().front(), false)
	call_deferred("positioning", fact2,  get_node("dzones").get_children().back(), true)

func set_up(player, faction, flipped):
	player.get_parent().remove_child(player)
	player.level = self
	player.faction = faction
	player.set_pos(get_node(str(faction.side) + "_spawn").get_pos())
	player.combat = true
	player.flip(flipped)
	
func positioning(faction, zone, flipped):
	zone.set_controlled(faction.side)
	for buildings in zone.get_node("buildings").get_children():
		var building_pos = buildings.get_global_pos()
		buildings.get_parent().call_deferred("remove_child", buildings)
		buildings.manual_placed = true
		buildings.defence_zone = zone
		buildings.flip(flipped)
		faction.call_deferred("add_child", buildings)
		buildings.call_deferred("set_global_pos", building_pos)
		buildings.call_deferred("positioning")
		buildings.call_deferred("initialize")

func check_win():
	if objective_list.back().get_ref().side == fact1.side or fact2.defence_list == []:
		win(fact1, fact2, true)
	elif objective_list.front().get_ref().side == fact2.side or fact1.defence_list == []:
		win(fact2, fact1, true)
#	if objective_list.back().get_ref().side == fact1.side or fact2.total_soldiers_remaining <= 0:
#		win(fact1, fact2, true)
#	elif objective_list.front().get_ref().side == fact2.side or fact1.total_soldiers_remaining <= 0:
#		win(fact2, fact1, false)

func win(win_faction, lose_faction, attack):
	for players in win_faction.player_list:
		if not players.AI:
			players.comment("yeehaw")
#			defending_land.completed = true

#	defending_land.infantry = win_faction.total_soldiers_remaining 
			
	for players in lose_faction.player_list:
		if not players.AI:
			players.comment("fucking shit," + "\n" + "fuck shit!")
	get_node("Timer").start()
	game_over = true

func close():
	for players in fact1.player_list:
		if not players.AI:
			if players.windows == true:
				players.build_mode_dup.close()
		if players.get_parent() != null:
			players.get_parent().remove_child(players)
				
	for players in fact2.player_list:
		if not players.AI:
			if players.windows == true:
				players.build_mode_dup.close()
			if players.get_parent() != null:
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