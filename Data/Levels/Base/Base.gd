extends Node2D
#var fact = preload("res://Faction.tscn").instance()
var game_over = false
var AI = preload("res://AI.tscn").instance()
var buildings = preload("res://buildings.tscn").instance()
var guns = preload("res://Guns.tscn")
var armour = preload("res://armour.tscn")
var survivor = preload("res://Allies.tscn").instance()
var enemies = preload("res://Enemies.tscn").instance()
var m = preload("res://Map.tscn").instance()
var r = preload("res://Report.tscn").instance()
var foliage = preload("res://foliage.tscn").instance()
var report
var map
var events
var faction
var enemy_faction

var fight = 0

var day = true
var dusk = false
var night = false

var set = false
var world

var objective_list = []

var survivor_list = []
var party

var night_time = 60
var time = 10
var total_time = 10
var day_count = 0

func attack(delta):
	var number = 10 + Global.day


	for numb in range(number):
		var zombie = enemies.get_node("Zombie_movement").duplicate()
		enemy_faction.add_child(zombie)
		zombie.set_global_pos(get_node("enemy_start").get_global_pos())
		if number > 30:
			break
	pass
func start_survivors():
	for number in range(2):
		survivor_list.append(survivor.get_node("Survivor").duplicate())
		
	var seperate = 0 
	for survivor in survivor_list:
		survivor.set_global_pos(Vector2(get_node("start_pos").get_global_pos().x + seperate, get_node("start_pos").get_global_pos().y))
		survivor.faction = faction
		faction.add_child(survivor)
		seperate += 10
		
		
func _ready():
	for cells in get_node("top").get_used_cells():
		var coords = get_node("top").map_to_world(cells)
		var fol = foliage.get_children()[round(rand_range(0, foliage.get_children().size() -1))].duplicate()
		fol.set_global_pos(Vector2(coords.x + 10 + get_global_pos().x, coords.y - 10))
		add_child(fol)
#		dark.show()
		
#	for cells in get_node("top").get_used_cells():
#		var coords = get_node("top").map_to_world(cells)
#		var fol = foliage.get_children()[round(rand_range(0, foliage.get_children().size() -1))].duplicate()
#		add_child(fol)
#		fol.set_global_pos(Vector2(coords.x + get_global_pos().x, coords.y - 10))
#		dark.show()

	Global = get_node("/root/Global")
	faction = get_node("Faction")
	if set == false:
		set = true
		map = m.duplicate()
		report = r.duplicate()
		add_child(report)
		report.get_node("report/report_ui").set_global_pos(Vector2(get_viewport().get_rect().size.x/2, get_viewport().get_rect().size.y - get_viewport().get_rect().size.y + 25))
		events = map.get_node("Events")
		enemy_faction = get_node("Enemy_faction")
		for zones in get_node("dzones").get_children():
			zones.init()
			objective_list.append(zones.myself)
#		world = get_parent()
		
		faction.side = "allies"
		faction.enemyside = "enemies"
		faction.sidenumber = 1
		faction.enemynumber = 2
		faction.enemynumberval = 4
		faction.points = 300
		

		
		enemy_faction.side = "enemies"
		enemy_faction.enemyside = "allies"
		enemy_faction.sidenumber = 2
		enemy_faction.enemynumber = 1
		enemy_faction.enemynumberval = 2
#		enemy_faction.points = 300
#		add_child(enemy_faction)
#		for spawn in get_node("enemy_start").get_children():
#			var zombie = enemies.get_node("Zombie_movement").duplicate()
#			enemy_faction.add_child(zombie)
#			zombie.set_global_pos(spawn.get_global_pos())
		start_survivors()
		call_deferred("positioning", faction, get_node("dzones").get_children().front(), false)
		pass
	else:
		var seperate = 0
#		survivor_list.clear()
		for survivor in Global.party:
			if survivor == null:
				pass
			else:
				survivor.get_ref().set_global_pos(Vector2(get_node("start_pos").get_global_pos().x + seperate, get_node("start_pos").get_global_pos().y))
				survivor.get_ref().faction = faction
				faction.add_child(survivor.get_ref())
				free_up(survivor)
				seperate += 10
#		Global.player.faction = faction
		Global.player.level = self
#		Global.player.set_global_pos(get_node("player_pos").get_global_pos())
#		faction.call_deferred("add_child", Global.player)
	Global.player.set_global_pos(get_node("player_pos").get_global_pos())
	Global.player.faction = faction
	Global.player.level = self
	faction.call_deferred("add_child", Global.player)
	Global.Base = self
func free_up(survivor):
	survivor.get_ref().building = null
	survivor.get_ref().job = ''
	survivor.get_ref().objective = null
#	if survivor.get_ref().AI:
#		survivor.get_ref().orders("patrol")
	
func positioning(faction, zone, flipped):
	for buildings in zone.get_node("buildings").get_children():
		var building_pos = buildings.get_global_pos()
		buildings.get_parent().call_deferred("remove_child", buildings)
		buildings.manual_placed = true
		buildings.defence_zone = zone
		buildings.build_time = 0
		buildings.flip(flipped)
		faction.call_deferred("add_child", buildings)
		buildings.call_deferred("set_global_pos", building_pos)
		buildings.call_deferred("positioning")
		buildings.call_deferred("initialize")

func food():
#		var health_loss = rand_range(0, faction.attacker_list.size()/Global.food)
		for npc in faction.attacker_list:
			Global.food -= 1
			if npc.get_ref().injured:
				if Global.food <= 0:
					Global.food = 0
				pass
			elif Global.food <= 0:
				Global.food = 0
				npc.get_ref().health -= 1
				npc.check_injured()
			else:
				if npc.get_ref().health < npc.get_ref().total_health:
					npc.get_ref().health += 1
					npc.check_injure()

func medicine():
	for npc in faction.attacker_list:
		if npc.get_ref().injured:
			if Global.medicine > 0:
				Global.medicine -= 1
				var random = int(rand_range(0, 100))
				if random > 20:
					npc.get_ref().heal()
				else:
					var random = int(rand_range(0, 100))
					if random < 5:
						npc.get_ref().dead()
			else:
				var random = int(rand_range(0, 100))
				if random > 50:
					npc.get_ref().heal()
				else:
					var random = int(rand_range(0, 100))
					if random < 20:
						npc.get_ref().dead()

func new_day():
	food()
	medicine()
	for npc in faction.attacker_list:
		if npc.get_ref().building == null and not npc.get_ref().injured:
			npc.get_ref().orders("patrol")
	get_node("ParallaxBackground/ParallaxLayer/night").hide()
	get_node("ParallaxBackground/ParallaxLayer/day").show()
	night = false
	day = true
	for building in faction.defence_list:
		building.get_ref().call_deferred("turn")

func day():
	for npc in faction.attacker_list:
		if npc.get_ref().building != null and not npc.get_ref().placed:
			npc.get_ref().building.get_ref().place(npc.get_ref())
	for building in faction.defence_list:
		building.get_ref().call_deferred("turn")
	Global.running_events()
	Global.player.building.get_ref().level()

func night():
	get_node("ParallaxBackground/ParallaxLayer/night").show()
	get_node("ParallaxBackground/ParallaxLayer/dusk").hide()
	dusk = false
	night = true
	set_fixed_process(true)
	pass

func dusk():
	var number = 0
	for npc in faction.attacker_list:
		if npc.get_ref().job == "Supply Run":
			free_up(npc)
		if npc.get_ref().building == null:
			npc.get_ref().hold_order = number
			npc.get_ref().orders("defend")
			number += 1
	get_node("ParallaxBackground/ParallaxLayer/dusk").show()
	get_node("ParallaxBackground/ParallaxLayer/day").hide()
	day = false
	dusk = true
#func turn():
#	for survivors in Global.party:
#		if survivor.get_ref().get_parent() != null:
#			survivor.get_ref().get_parent().remove_child(survivor)
#		survivor.get_ref()
func _fixed_process(delta):
	night_time -= delta
	time -= delta
	if time <= 0:
		time = total_time
		attack(delta)
		
	if night_time <= 0:
		night_time = 60
		day_count = 0
		set_fixed_process(false)
		new_day()

	
	