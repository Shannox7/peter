extends Node2D
var deploy = preload("res://Deployables.tscn")
var allies = preload("res://Allies.tscn")
var icons = preload("res://Inventory_icons.tscn")
var build = preload("res://Buildings.tscn")

var Global

var on_supply_run = false

var construction
var selected

var pos

var description

var supply_run = false


var select_party = false

var menu = 0

var upgrade_x = 0
var left_list = []
var right_list = []
var slot = 0
var slots = []
var occupying = false
var select_occupy = false
var survivor_cards = []

var prevx = 0

var inv_list = 0
var inv = []

var current_list = 0
var listy = 0
var listx = 0
var hud_list = [[],[]]
var hud_display_list = [[],[]]

var infantryd
var mined
var turretd
var walld
var sandbag_nestd

var building_build
var deploy_build

var engineer
var infantry
var mine
var turret
var wall
var tall_wall
var sandbag_nest
var foxhole
var war_factory
var barracks
var helicopter_pad
var air_field


var faction
var level

var move_speed = 300
var scroll_speed = .05
var scroll_speed_delay = .2

var build_menu = false
var upgrade_menu = false
var inventory_menu = false


var building = false
var upgrading = false

var up
var down
var left
var right

var player

var deploys

var highlight_total = 1.75
var highlighting = false
var highlight_reverse = false
var highlight = 1

var yes_no = false
var yes_no_obj = ""
var x = 1

func _ready():
	faction = get_parent()
	level = get_parent().get_parent()
	Global = get_node("/root/Global")
	deploys = get_node("build_upgrade/build_ui/deploys")
	get_node("build_upgrade/upgrade_ui").hide()
	get_node("build_upgrade/survivor_ui").hide()
	get_node("build_upgrade/build_ui").hide()
	infantryd = icons.instance().get_node("Recruit/Infantry")
	mined = icons.instance().get_node("Deployables/Mine")
	turretd = icons.instance().get_node("Deployables/Turret")
	walld = icons.instance().get_node("Buildables/steel_wall")
	sandbag_nestd = icons.instance().get_node("Buildables/sandbags")
	
	sandbag_nest = build.instance().get_node(faction.faction + "/Defence/sandbag_bunker")
	foxhole = build.instance().get_node(faction.faction + "/Defence/foxhole")
	infantry = allies.instance().get_node("Infantry")
	engineer = allies.instance().get_node("Engineer")
	turret = deploy.instance().get_node("machinegun_turret")
	mine = deploy.instance().get_node("mine")
	wall = build.instance().get_node(faction.faction + "/Barricades/steel_wall")
	tall_wall = build.instance().get_node(faction.faction + "/Barricades/tall_steel_wall")
#	building_build = build.instance().get_node("Build")
	deploy_build = deploy.instance().get_node("Build")
	barracks = build.instance().get_node(faction.faction + "/Resource/Food")
	war_factory = build.instance().get_node(faction.faction + "/Spawn_buildings/war_factory")
	helicopter_pad = build.instance().get_node(faction.faction + "/Spawn_buildings/helicopter_pad")
	air_field =  build.instance().get_node(faction.faction + "/Spawn_buildings/Air_field")
	hud_list = [[barracks.duplicate(), air_field.duplicate()],[war_factory.duplicate()],[tall_wall.duplicate(), helicopter_pad.duplicate()], [sandbag_nest.duplicate()]]
	hud_display_list = [[infantryd, turretd.duplicate()],[turretd], [walld, walld.duplicate()], [sandbag_nestd]]
	
	pass
	
func start(p):
#	if upgrading and faction.defence_list != []:
#		upgrade_closest(player)

#	if building:
#		selector()
#		pos = null
#		for point in level.objective_list:
#			if point.get_ref().side == faction.side:
#				if pos == null:
#					pos = point
#				elif player.get_global_pos().distance_to(point.get_ref().get_global_pos()) < player.get_global_pos().distance_to(pos.get_ref().get_global_pos()):
#					pos = point
#		get_node("follow").set_global_pos(Vector2(pos.get_ref().get_global_pos().x, pos.get_ref().get_global_pos().y - 20 ))
#	


	player = p.get_ref()
	player.get_node("Camera2D").clear_current()
	get_node("follow/Camera2D").make_current()
	player.windows = true
	on_supply_run = Global.on_supply_run
	if on_supply_run:
		menu = 3
	menu()
	set_process_input(true)
	set_fixed_process(true)

#	display()
#	display_column()
#	selector()

func yes_no(obj):
	yes_no = true
	x = 1
	get_node("build_upgrade/yes_no").show()
	get_node("build_upgrade/yes_no").set_global_pos(Vector2(get_viewport().get_rect().size.x/2, get_viewport().get_rect().size.y/2))
	get_node("build_upgrade/yes_no/Label").set_text("Are you sure you want to destroy this building?")
	get_node("build_upgrade/yes_no/Sprite").set_pos(get_node("build_upgrade/yes_no/no").get_pos())
	yes_no_obj = obj
func yes():
	if yes_no_obj == "destroy":
		destroy()
	x = 1
	yes_no = false
	get_node("build_upgrade/yes_no").hide()
	pass
func no():
	yes_no = false
	get_node("build_upgrade/yes_no").hide()

func destroy():
	if selected.food_cost != 0:
		Global.food += selected.food_cost/2
	if selected.scrap_cost != 0:
		Global.scrap += selected.scrap_cost/2
	highlight(false)
	selected.death()
	display()
	upgrade_x = 0
	selector()
	
func close():
	if !player:
		pass
	else:
		build_menu = false
		upgrade_menu = false
		inventory_menu = false
#		get_node("follow/Camera2D").clear_current()
#		set_process_input(false)
#		set_fixed_process(false)
		player.get_node("Camera2D").make_current()
		player.set_process_input(true)
#		get_node("build_upgrade/upgrade_ui").hide()
#		get_node("build_upgrade/survivor_ui").hide()
#		get_node("build_upgrade/build_ui").hide()
		if not Global.on_supply_run:
			if level.map.get_parent() != null:
				level.map.get_parent().remove_child(level.map)
		player.windows = false
	remove_building()
	queue_free()
	
func clear_(list):
	for items in list:
		items.call_deferred("queue_free")
	list.clear()

func display():
	get_node("build_upgrade/build_ui").set_global_pos(Vector2(50, get_viewport().get_rect().size.y - get_viewport().get_rect().size.y + 25))
	get_node("build_upgrade/upgrade_ui").set_global_pos(Vector2(50, get_viewport().get_rect().size.y - get_viewport().get_rect().size.y + 25))
	get_node("build_upgrade/survivor_ui").set_global_pos(Vector2(400, get_viewport().get_rect().size.y - get_viewport().get_rect().size.y + 25))
	get_node("build_upgrade/inventory_ui").set_global_pos(Vector2(400, get_viewport().get_rect().size.y - get_viewport().get_rect().size.y + 25))
	clear_(left_list)
	var number = 0
	if upgrade_menu:
		for building in player.faction.defence_list:
			var building_card = get_node("build_upgrade/upgrade_ui/building").duplicate()
			left_list.append(building_card)
			building_card.get_node("Label").set_text(building.get_ref().name)
			if building.get_ref().occupency == 0:
				building_card.get_node("Label1").set_text("n/a")
			var occups = 0
			for npc in building.get_ref().occupents:
				if npc != null:
					occups += 1
				building_card.get_node("Label1").set_text(str(occups) + "/" + str(building.get_ref().occupency))
			building_card.set_global_pos(Vector2(get_node("build_upgrade/upgrade_ui/building").get_pos().x, get_node("build_upgrade/upgrade_ui/building").get_pos().y + (30 * number)))
			get_node("build_upgrade/upgrade_ui").add_child(building_card)
			building_card.show()
			number += 1
			
	if supply_run:
		number = 0
		for event in level.events.event_list:
			var event_card = get_node("build_upgrade/upgrade_ui/building").duplicate()
			left_list.append(event_card)
			event_card.get_node("Label").set_text(event.get_ref().name)
			if event.get_ref().occupency == 0:
				event_card.get_node("Label1").set_text("n/a")
			var occups = 0
			for npc in event.get_ref().occupents:
				if npc != null:
					occups += 1
				event_card.get_node("Label1").set_text(str(occups) + "/" + str(event.get_ref().occupency))
			event_card.set_global_pos(Vector2(get_node("build_upgrade/upgrade_ui/building").get_pos().x, get_node("build_upgrade/upgrade_ui/building").get_pos().y + (30 * number)))
			get_node("build_upgrade/upgrade_ui").add_child(event_card)
			event_card.show()
			number += 1
			
	if upgrade_menu or supply_run:
		if listx == 0:
			selector()

	if inventory_menu:
		get_node("build_upgrade/survivor_ui").set_global_pos(Vector2(50, get_viewport().get_rect().size.y - get_viewport().get_rect().size.y + 25))
		number = 1
		clear_(survivor_cards)
		var survivor_card = get_node("survivor_card").duplicate()
		survivor_card.set_pos(Vector2(get_node("build_upgrade/survivor_ui").get_pos().x, get_node("build_upgrade/survivor_ui").get_pos().y))
		survivor_card.get_node("Label").set_text(player.name)
		survivor_card.get_node("Label1").set_text(player.job)
		survivor_cards.append(survivor_card)
		get_node("build_upgrade/survivor_ui").add_child(survivor_card)
		survivor_card.show()
		for npc in player.faction.attacker_list:
			var survivor_card = get_node("survivor_card").duplicate()
			survivor_card.set_pos(Vector2(get_node("build_upgrade/survivor_ui").get_pos().x, get_node("build_upgrade/survivor_ui").get_pos().y + (30 * number)))
			survivor_card.get_node("Label").set_text(npc.get_ref().name)
			survivor_card.get_node("Label1").set_text(npc.get_ref().job)
			survivor_cards.append(survivor_card)
			get_node("build_upgrade/survivor_ui").add_child(survivor_card)
			survivor_card.show()
			number += 1
		number = 0
		clear_(right_list)
		inv.clear()
		for item in Global.pack:
			var item1  = item
			if inv_list == 0 and item.is_in_group("weapons"):
				display_inv(item1, number)
				number += 1
			elif inv_list == 1 and item.is_in_group("head"):
				display_inv(item1, number)
				number += 1
			elif inv_list == 2 and item.is_in_group("body"):
				display_inv(item1, number)
				number += 1
	elif Global.on_supply_run:
		get_node("build_upgrade/survivor_ui").set_global_pos(Vector2(50, get_viewport().get_rect().size.y - get_viewport().get_rect().size.y + 25))
		number = 1
		clear_(survivor_cards)
		var survivor_card = get_node("survivor_card").duplicate()
		survivor_card.set_pos(Vector2(get_node("build_upgrade/survivor_ui").get_pos().x, get_node("build_upgrade/survivor_ui").get_pos().y))
		survivor_card.get_node("Label").set_text(player.name)
		survivor_card.get_node("Label1").set_text(player.job)
		survivor_cards.append(survivor_card)
		get_node("build_upgrade/survivor_ui").add_child(survivor_card)
		survivor_card.show()
		for npc in player.faction.attacker_list:
#			if npc.get_ref().AI:
			var survivor_card = get_node("survivor_card").duplicate()
			survivor_card.set_pos(Vector2(get_node("build_upgrade/survivor_ui").get_pos().x, get_node("build_upgrade/survivor_ui").get_pos().y + (30 * number)))
			survivor_card.get_node("Label").set_text(npc.get_ref().name)
			survivor_card.get_node("Label1").set_text(npc.get_ref().job)
			survivor_cards.append(survivor_card)
			get_node("build_upgrade/survivor_ui").add_child(survivor_card)
			survivor_card.show()
			number += 1
		number = 0
		clear_(right_list)
		inv.clear()
		for item in Global.supply_run_pack:
			var item1  = item
			if inv_list == 0 and item.is_in_group("weapons"):
				display_inv(item1, number)
				number += 1
			elif inv_list == 1 and item.is_in_group("head"):
				display_inv(item1, number)
				number += 1
			elif inv_list == 2 and item.is_in_group("body"):
				display_inv(item1, number)
				number += 1
			elif inv_list == 3 and item.is_in_group("misc"):
				display_inv(item1, number)
				number += 1
		get_node("build_upgrade/inventory_ui/carry_weight").set_text("Weight: " + str(Global.supply_run_weight) + "/" +  str(Global.supply_run_carry_weight))
#	var number = 0
#	for lists in hud_display_list:
#		lists[0].set_pos(deploys.get_pos() + get_node("build_upgrade/build_ui/deploys/box" + str(number)).get_pos())
#		if lists[0].get_parent() != null:
#			lists[0].get_parent().remove_child(lists[0])
#		get_node("build_upgrade/build_ui").add_child(lists[0])
#		number += 1
#	get_node("build_upgrade/build_ui/deploys/box" + str(prevx) + "/Label").show()
#	get_node("build_upgrade/build_ui/deploys/box" + str(listy) + "/Label").hide()
#	get_node("build_upgrade/build_ui/deploys/box" + str(prevx) + "/description").set_text("")
#	get_node("build_upgrade/build_ui/deploys/box" + str(listy) + "/description").set_text(str(hud_list[listy][0].name) + "\n" + "Cost: " + str(hud_list[listy][0].cost))
func npc_list():
	var number = 0
	clear_(survivor_cards)
	for npc in faction.attacker_list:
		var survivor_card = get_node("survivor_card").duplicate()
		survivor_card.set_pos(Vector2(get_node("build_upgrade/survivor_ui").get_pos().x, get_node("build_upgrade/survivor_ui").get_pos().y + (40 * number)))
		survivor_card.get_node("Label").set_text(npc.get_ref().name)
		survivor_card.get_node("Label2").set_text(npc.get_ref().job)
		if selected.is_in_group("supply run"):
			survivor_card.get_node("Label1").set_text("Fight skill: " + str(npc.get_ref().fight_skill))
		elif selected.build_time > 0:
			survivor_card.get_node("Label1").set_text("Labour skill: " + str(npc.get_ref().labour_skill))
		elif selected.skill == "labour":
			survivor_card.get_node("Label1").set_text("Labour skill: " + str(npc.get_ref().labour_skill))
		elif selected.skill == "doctor":
			survivor_card.get_node("Label1").set_text("Doctor skill: " + str(npc.get_ref().doctor_skill))
		elif selected.skill == "fight":
			survivor_card.get_node("Label1").set_text("Fight skill: " + str(npc.get_ref().fight_skill))
		elif selected.skill == "":
			survivor_card.get_node("Label1").set_text("")
		survivor_cards.append(survivor_card)
		get_node("build_upgrade/survivor_ui").add_child(survivor_card)
		survivor_card.show()
		number += 1
		
func display_inv(item, number):
	var survivor_card = get_node("survivor_card").duplicate()
	survivor_card.set_pos(Vector2(get_node("build_upgrade/inventory_ui").get_pos().x, get_node("build_upgrade/inventory_ui").get_pos().y + (30 * number)))
	survivor_card.get_node("Label").set_text(item.name)
	if item.get_parent() != null:
		survivor_card.get_node("Label1").set_text(item.get_parent().get_parent().get_parent().name)
	else:
		survivor_card.get_node("Label1").set_text("")
	right_list.append(survivor_card)
	inv.append(item)
	get_node("build_upgrade/inventory_ui").add_child(survivor_card)
	survivor_card.show()
	
func display_column():
	var number = 0
	for items in hud_display_list[listy]:
		items.set_pos(Vector2(get_node("build_upgrade/build_ui/Position2D").get_pos().x, get_node("build_upgrade/build_ui/Position2D").get_pos().y + (24 * number)))
#		items.set_pos(Vector2(deploys.get_pos().x + get_node("build_upgrade/build_ui/deploys/box" + str(listy)).get_pos().x, deploys.get_pos().y + get_node("build_upgrade/build_ui/deploys/box" + str(listy)).get_pos().y - (24 * number)))
		if items.get_parent() != null:
			items.get_parent().remove_child(items)
		get_node("build_upgrade/build_ui").add_child(items)
		number += 1

func clear_column(x):
	for items in hud_display_list[x]:
		items.get_parent().remove_child(items)

func remove_building():
	if construction != null:
		construction.queue_free()
		selected.queue_free()
		construction = null
		selected = null

func drop():
	if Global.on_supply_run:
		if not inv[listy].is_equipped:
			Global.supply_run_weight -= inv[listy].weight
	inv[listy].drop()
	pass

func equip():
	var equip_slot
	if inv_list == 0:
		equip_slot = "primaryGun"
	elif inv_list == 1:
		equip_slot = "headArmour"
	elif inv_list == 2:
		equip_slot = "bodyArmour"
	if inv[listy].is_equipped == true:
		if inv[listy].slot == "primaryGun":
			if inv[listy] in inv[listy].get_parent().get_parent().get_parent().primaryGun:
				inv[listy].get_parent().get_parent().get_parent().unequip_change("primaryGun")
			if inv[listy] in inv[listy].get_parent().get_parent().get_parent().secondaryGun:
				inv[listy].get_parent().get_parent().get_parent().unequip_change("secondaryGun")
		else:
			inv[listy].get_parent().get_parent().get_parent().unequip_change(inv[listy].slot)
		inv[listy].get_parent().remove_child(inv[listy])
		inv[listy].is_equipped = false
	if current_list == 0:
		player.equip(inv[listy], false, equip_slot)
	else:
		faction.attacker_list[current_list - 1].get_ref().equip(inv[listy], false, equip_slot)

	display()
	pass

func selector():
	remove_building()
	if description != null:
		description.queue_free()
		description = null
	if build_menu:
		if listx == 1:
			selected = hud_list[current_list][listy].duplicate()
			construction = selected.builder().duplicate()
			faction.add_child(selected)
			construction.structure = selected
			faction.add_child(construction)
			get_node("build_upgrade/build_ui/deploys/box9").set_pos(Vector2(get_node("build_upgrade/build_ui/Position2D").get_pos().x, get_node("build_upgrade/build_ui/Position2D").get_pos().y + (24 * listy)))
			building_description()
	#		highlight(true)
		else:
			get_node("build_upgrade/build_ui/deploys/box9").set_pos(Vector2(get_node("build_upgrade/build_ui/deploys/box0").get_pos().x, get_node("build_upgrade/build_ui/Position2D").get_pos().y + (24 * listy)))
		
	elif upgrade_menu:
		get_node("build_upgrade/survivor_ui").show()
		if faction.defence_list == []:
			select_occupy = false
			occupying = false
			pass
		elif select_occupy:
			get_node("build_upgrade/upgrade_ui/selector").set_global_pos(survivor_cards[listy].get_global_pos())
		else:
			if occupying:
				get_node("build_upgrade/upgrade_ui/selector").set_pos(slots[listy].get_pos())
			else:
#				highlight(false)
				get_node("follow").set_global_pos(Vector2(faction.defence_list[upgrade_x].get_ref().get_global_pos().x, faction.defence_list[upgrade_x].get_ref().get_global_pos().y - 20))
				selected = faction.defence_list[upgrade_x].get_ref()
				get_node("build_upgrade/upgrade_ui/selector").set_pos(left_list[upgrade_x].get_pos())
		#		get_node("build_upgrade/upgrade_ui").set_global_pos(Vector2(50, get_viewport().get_rect().size.y - get_viewport().get_rect().size.y + 25))
		#		get_node("build_upgrade/upgrade_ui/Label").set_global_pos(Vector2(selected.get_global_pos().x, selected.get_global_pos().y + 50))
		#		get_node("build_upgrade/upgrade_ui/Label1").set_global_pos(Vector2(selected.get_global_pos().x, selected.get_global_pos().y + 40))
		#		get_node("build_upgrade/upgrade_ui/building/Label").set_text(selected.name)
		#		if selected.occupents == []:
		#			get_node("build_upgrade/upgrade_ui/building/Label1").set_text(str(0) + "/" + str(selected.occupency))
		#		elif selected.occupency > 0:
		#			get_node("build_upgrade/upgrade_ui/building/Label1").set_text(str(selected.occupents.size() -1) + "/" + str(selected.occupency))
		#		else:
		#			get_node("build_upgrade/upgrade_ui/building/Label1").set_text("n/a")
				highlight(true)
				occupying()
			npc_list()
		upgrade_description()
	elif supply_run:
		get_node("build_upgrade/survivor_ui").show()
		if select_occupy:
			get_node("build_upgrade/upgrade_ui/selector").set_global_pos(survivor_cards[listy].get_global_pos())
		else:
			if occupying:
				get_node("build_upgrade/upgrade_ui/selector").set_pos(slots[listy].get_pos())
			else:
				selected = level.events.event_list[upgrade_x].get_ref()
				occupying()
				get_node("follow").set_global_pos(Vector2(level.events.event_list[upgrade_x].get_ref().get_global_pos().x, level.events.event_list[upgrade_x].get_ref().get_global_pos().y))
				get_node("build_upgrade/upgrade_ui/selector").set_pos(left_list[upgrade_x].get_pos())
				highlight(true)
			npc_list()
		supply_run_description()
	elif inventory_menu or on_supply_run:
		get_node("build_upgrade/survivor_ui").show()
		get_node("build_upgrade/inventory_ui").show()
		if select_occupy:
			get_node("build_upgrade/inventory_ui/selector").show()
			if right_list == []:
				get_node("build_upgrade/inventory_ui/selector").hide()
			else:
				get_node("build_upgrade/inventory_ui/selector").set_global_pos(right_list[listy].get_global_pos())
		else:
			if listy == 0:
				selected = Global.player
			else:
				slot = listy - 1
				selected = faction.attacker_list[slot].get_ref()
			get_node("follow").set_global_pos(selected.get_global_pos())
			get_node("build_upgrade/inventory_ui/selector").set_global_pos(survivor_cards[listy].get_global_pos())
		call_deferred("description")

func upgrade_description():
	description = get_node("upgrade_description").duplicate()

	get_node("build_upgrade").add_child(description)
	description.set_global_pos(Vector2(get_viewport().get_rect().size.x/2, get_viewport().get_rect().size.y - get_viewport().get_rect().size.y  + 30))

	description.get_node("desc").set_bbcode(str(selected.name) + "\n")
	
	if selected.build_time > 0:
		var time = 0
		var turns
		for occupent in selected.occupents:
			if occupent != null:
				time += occupent.get_ref().labour_skill
		if time == 0:
			description.get_node("desc").append_bbcode("build time: "+ str(selected.build_time) + "\n")
			description.get_node("desc").append_bbcode("Build time: n/a"  + "\n")
		else:
			turns = int(selected.build_time/time)
			if selected.build_time%time > 0:
#				print(str(selected.build_time%time))
				turns += 1
			description.get_node("desc").append_bbcode("build time: " + str(selected.build_time) + " - " + str(time) + "\n")
			description.get_node("desc").append_bbcode("Build time: " + str(turns) + " turns"  + "\n")

	
	elif selected.is_in_group("resource"):
		description.get_node("desc").append_bbcode("Resources per harvest: " + "\n")
	
		if selected.scrap > 0:
			description.get_node("desc").append_bbcode("Scrap: " + str(selected.scrap) + "\n")
		if selected.food > 0:
			description.get_node("desc").append_bbcode("Food: " + str(selected.food) + "\n")
		var time = 0
		var turns
		for occupent in selected.occupents:
			if occupent != null:
				time += occupent.get_ref().labour_skill
		if time == 0:
			description.get_node("desc").append_bbcode("Harvest time: " + str(selected.harvest_time) + "\n")
			description.get_node("desc").append_bbcode("Time until harvest: n/a "  + "\n")
		else:
			turns = int(selected.harvest_time/time)
			if selected.harvest_time%time > 0:
				turns += 1
			description.get_node("desc").append_bbcode("Harvest time: " + str(selected.harvest_time) + " - " + str(time) + "\n")
			description.get_node("desc").append_bbcode("Time until harvest: " + str(turns) + " turns"  + "\n")
	
	elif selected.is_in_group("defence"):
		description.get_node("desc").append_bbcode("Health: " + str(selected.health) + "/" + str(selected.total_health) + "\n")
		if selected.damage > 0:
			description.get_node("desc").append_bbcode("Damage: " + str(selected.damage) + "\n")
	description.show()
	
func building_description():
	description = get_node("build_description").duplicate()

	get_node("build_upgrade").add_child(description)
	description.set_global_pos(Vector2(get_viewport().get_rect().size.x/2, get_viewport().get_rect().size.y - get_viewport().get_rect().size.y  + 30))

	description.get_node("desc").set_bbcode(str(selected.name) + "\n")
	description.get_node("desc").append_bbcode("Cost: " +"\n")
	if selected.scrap_cost > 0:
		description.get_node("desc").append_bbcode("Scrap: " + str(selected.scrap_cost)  + "\n")
	if selected.food_cost > 0:
		description.get_node("desc").append_bbcode("Food: " + str(selected.food_cost)  + "\n")
	var time = 0
	var turns

	description.get_node("desc").append_bbcode("Build time: " + str(selected.build_time)  + "\n")
	
	if selected.is_in_group("resource"):
		description.get_node("desc").append_bbcode("Resources per harvest: ")
	
		if selected.scrap > 0:
			description.get_node("desc").append_bbcode("Scrap: " + str(selected.scrap) + "\n")
		if selected.food > 0:
			description.get_node("desc").append_bbcode("Food: " + str(selected.food) + "\n")
	elif selected.is_in_group("defence"):
		description.get_node("desc").append_bbcode("Health: " + str(selected.health) + "/" + str(selected.total_health) + "\n")
		if selected.damage > 0:
			description.get_node("desc").append_bbcode("Damage: " + str(selected.damage) + "\n")
	description.show()
	
func supply_run_description():
	description = get_node("build_description").duplicate()

	get_node("build_upgrade").add_child(description)
	description.set_global_pos(Vector2(get_viewport().get_rect().size.x/2, get_viewport().get_rect().size.y - get_viewport().get_rect().size.y  + 30))

	description.get_node("desc").set_bbcode(str(selected.name) + "\n")
	description.get_node("desc").append_bbcode("Difficulty: " + str(selected.difficulty) + "\n")
	
	var fight = 0
	for npc in selected.occupents:
		if npc != null:
			fight += npc.get_ref().fight_skill
	if selected.difficulty - fight <= 0:
		fight = selected.difficulty
	if fight > 0:
		description.get_node("desc").append_bbcode("Chance to fail: " + str(selected.difficulty - fight) + "\n")
	description.show()
	
func description():
	description = get_node("description").duplicate()

	get_node("build_upgrade").add_child(description)
	description.set_global_pos(Vector2(get_viewport().get_rect().size.x/2, get_viewport().get_rect().size.y - get_viewport().get_rect().size.y  + 30))

	description.get_node("desc").set_bbcode(str(selected.name) + "\n")
	description.get_node("desc").append_bbcode("Health: " + str(selected.health) + "/" + str(selected.total_health) + "\n")
	description.get_node("desc").append_bbcode("Carry Weight: " + str(selected.carry_weight) + "\n")
	if selected.AI:
		description.get_node("desc").append_bbcode("Fight: " + str(selected.fight_skill) + "\n")
		description.get_node("desc").append_bbcode("Labour: " + str(selected.labour_skill) + "\n")
		description.get_node("desc").append_bbcode("Doctor: " + str(selected.doctor_skill) + "\n")

	
	if selected.primaryGun != []:
		var gun = selected.primaryGun[0].duplicate()
		description.get_node("weapon").add_child(gun)
		gun.set_global_pos(description.get_node("weapon/Sprite").get_global_pos())
		description.get_node("weapon/Label").set_text(selected.primaryGun[0].name)
		description.get_node("weapon/Label1").set_text("DPS: " + str(1/selected.primaryGun[0].fire_rate * selected.primaryGun[0].damage))
	else:
		description.get_node("weapon/Label").set_text("empty")
		description.get_node("weapon/Label1").set_text("")
	if selected.headArmour != []:
		var head = selected.headArmour[0].duplicate()
		description.get_node("headArmour").add_child(head)
		head.set_global_pos(description.get_node("headArmour/Sprite").get_global_pos())
		description.get_node("headArmour/Label").set_text(selected.headArmour[0].name)
		description.get_node("headArmour/Label1").set_text("Armour: " + str(selected.headArmour[0].armour))
	else:
		description.get_node("headArmour/Label").set_text("empty")
		description.get_node("headArmour/Label1").set_text("")
	if selected.bodyArmour != []:
		var body = selected.bodyArmour[0].duplicate()
		description.get_node("bodyArmour").add_child(body)
		body.set_global_pos(description.get_node("bodyArmour/Sprite").get_global_pos())
		description.get_node("bodyArmour/Label").set_text(selected.bodyArmour[0].name)
		description.get_node("bodyArmour/Label1").set_text("Armour: " + str(selected.bodyArmour[0].armour))
	else:
		description.get_node("bodyArmour/Label").set_text("empty")
		description.get_node("bodyArmour/Label1").set_text("")
	description.show()
func sorting_by_distance(one, two):
	if one.get_ref().get_global_pos().x < two.get_ref().get_global_pos().x:
		return true

func upgrade_closest(loc):
	var obj = null
	for point in faction.defence_list:
		if obj == null:
			obj = point
		elif loc.get_global_pos().distance_to(point.get_ref().get_global_pos()) < loc.get_global_pos().distance_to(obj.get_ref().get_global_pos()):
			obj = point
	get_node("follow").set_global_pos(Vector2(obj.get_ref().get_global_pos().x, obj.get_ref().get_global_pos().y - 20 ))
	upgrade_x = faction.defence_list.find(obj)
	selected = faction.defence_list[upgrade_x].get_ref()
	highlight(true)

func menu():
	if upgrade_menu and faction.defence_list != []:
		highlight(false)
	if supply_run:
		highlight(false)
	if not on_supply_run:
		if level.map.get_parent() != null:
			level.map.get_parent().remove_child(level.map)
	build_menu = false
	upgrade_menu = false
	inventory_menu = false
	get_node("build_upgrade/upgrade_ui").hide()
	get_node("build_upgrade/survivor_ui").hide()
	get_node("build_upgrade/build_ui").hide()
	get_node("build_upgrade/inventory_ui").hide()
	current_list = 0
	listy = 0
	listx = 0
	upgrade_x = 0
	building = false
	occupying = false
	select_occupy = false
	supply_run = false
	if menu == 0:
#		get_node("follow").set_global_pos(player.get_global_pos())
		build_menu = true
		display()
		display_column()
		get_node("build_upgrade/build_ui").show()

	elif menu == 1:
		upgrade_menu = true
		get_node("build_upgrade/upgrade_ui").show()
		get_node("build_upgrade/survivor_ui").show()
		remove_building()
		if faction.defence_list != []:
			faction.defence_list.sort_custom(self,"sorting_by_distance")
			upgrade_closest(get_node("follow"))
		display()

	elif menu == 2:
		supply_run = true
		get_node("build_upgrade/upgrade_ui").show()
		get_node("build_upgrade/survivor_ui").show()
		level.add_child(level.map)
#		remove_building()
#		faction.defence_list.sort_custom(self,"sorting_by_distance")
#		upgrade_closest(get_node("follow"))
		display()
	elif menu == 3:
		if not on_supply_run:
			inventory_menu = true
		get_node("build_upgrade/survivor_ui").show()
		get_node("build_upgrade/inventory_ui").show()
		display()
		pass
	selector()

func occupy():
	if selected.occupents[slot] != null:
		selected.remove_occupent(slot)
	if player.faction.attacker_list[listy].get_ref().building != null:
		var number = player.faction.attacker_list[listy].get_ref().building.get_ref().occupents.find(player.faction.attacker_list[listy].get_ref().myself)
		player.faction.attacker_list[listy].get_ref().building.get_ref().remove_occupent(number)
	selected.occupy(player.faction.attacker_list[listy].get_ref(), slot)
	occupying()
	display()

func player_occupy():
	if selected.occupents[slot] != null:
		selected.remove_occupent(slot)
	if player.building != null:
		var number = player.building.get_ref().occupents.find(player.myself)
		player.building.get_ref().remove_occupent(number)
	selected.occupy(player, slot)
	occupying()
	display()

func occupying():
	clear_(slots)
	var number = 0
	for slot_number in range(selected.occupency):
		var slot_card = get_node("survivor_card").duplicate()
		slot_card.set_pos(Vector2(get_node("build_upgrade/upgrade_ui/Position2D").get_pos().x, get_node("build_upgrade/upgrade_ui/Position2D").get_pos().y + (number * 30)))
		slots.append(slot_card)
		if selected.occupents[slot_number] != null:
			slot_card.get_node("Label").set_text(selected.occupents[number].get_ref().name)
			if selected.occupents[number].get_ref() == player:
				pass
			elif selected.is_in_group("supply run"):
				slot_card.get_node("Label1").set_text("Fight skill: " + str(selected.occupents[number].get_ref().fight_skill))
			elif selected.build_time > 0:
				slot_card.get_node("Label1").set_text("Labour skill: " + str(selected.occupents[number].get_ref().labour_skill))
			elif selected.skill == "labour":
				slot_card.get_node("Label1").set_text("Labour skill: " + str(selected.occupents[number].get_ref().labour_skill))
			elif selected.skill == "doctor":
				slot_card.get_node("Label1").set_text("Doctor skill: " + str(selected.occupents[number].get_ref().doctor_skill))
			elif selected.skill == "fight":
				slot_card.get_node("Label1").set_text("Fight skill: " + str(selected.occupents[number].get_ref().fight_skill))
			elif selected.skill == "":
				slot_card.get_node("Label1").set_text("")
		else:
			slot_card.get_node("Label").set_text("Open")
			slot_card.get_node("Label1").set_text("")
			
		get_node("build_upgrade/upgrade_ui").add_child(slot_card)
		slot_card.show()
		number += 1
	pass
func _input(event):
	if yes_no:
		if event.is_action_pressed("select_left"):
			x = 0
			get_node("build_upgrade/yes_no/Sprite").set_pos(get_node("build_upgrade/yes_no/yes").get_pos())
		elif event.is_action_pressed("select_right"):
			x = 1
			get_node("build_upgrade/yes_no/Sprite").set_pos(get_node("build_upgrade/yes_no/no").get_pos())
		if event.is_action_pressed("interact"):
			if x == 0:
				yes()
			else:
				no()
	elif build_menu:
		prevx = listy
		if event.is_action_pressed("select_down"):
			if listx > 0:
				if listy == hud_display_list[current_list].size() - 1:
					listy = 0
				else:
					listy += 1
				display()
			else:
				clear_column(listy)
				if listy == hud_display_list.size() - 1:
					listy = 0
				else:
					listy += 1
				display_column()
			selector()
		elif event.is_action_pressed("select_up"):
			if listx > 0:
				if listy == 0:
					listy = hud_display_list[current_list].size() - 1
				else:
					listy -= 1
				display()
			else:
				clear_column(listy)
				if listy == 0:
					listy = hud_display_list.size() - 1
				else:
					listy -= 1
				display_column()
			selector()
				
		elif event.is_action_pressed("select_left"):
			if listx == 1:
				listx = 0
				listy = current_list
				building = false
				selector()

		elif event.is_action_pressed("select_right"):
			if listx == 0:
				current_list = listy
				listx = 1
				listy = 0
				building = true
				selector()

		if building:
			if event.is_action_pressed("place") and construction.placeable:
				if Global.scrap >= selected.scrap_cost and Global.food >= selected.food_cost:
					Global.scrap -= selected.scrap_cost
					Global.food -= selected.food_cost
					construction.activate()
					construction = null
	#				selected = null
					selector()
					player.update_hud()
				else:
					player.comment("I cant afford this!")
	
			if event.is_action_pressed("ui_right"):
				right = true
				get_node("follow").set_global_pos(Vector2(get_node("follow").get_global_pos().x + 20, get_node("follow").get_global_pos().y))
			if event.is_action_pressed("ui_left"):
				left = true
				get_node("follow").set_global_pos(Vector2(get_node("follow").get_global_pos().x - 20, get_node("follow").get_global_pos().y))
			if event.is_action_pressed("ui_up"):
				up = true
				get_node("follow").set_global_pos(Vector2(get_node("follow").get_global_pos().x, get_node("follow").get_global_pos().y  - 20))
			if event.is_action_pressed("ui_down"):
				down = true
				get_node("follow").set_global_pos(Vector2(get_node("follow").get_global_pos().x, get_node("follow").get_global_pos().y  + 20))
			if event.is_action_released("ui_down") or event.is_action_released("ui_up") or event.is_action_released("ui_right") or event.is_action_released("ui_left"):
				scroll_speed_delay = .2
				scroll_speed = .05
				right = false
				left = false
				up = false
				down = false
			
	elif supply_run:
		if select_occupy:
			if event.is_action_pressed("select_down"):
				if listy < survivor_cards.size() - 1:
					listy += 1
					selector()
			elif event.is_action_pressed("select_up"):
				if listy > 0:
					listy -= 1
					selector()
			elif event.is_action_pressed("select_right"):
				pass
			elif event.is_action_pressed("select_left"):
				listx -= 1
				listy = 0
				select_occupy = false
				selector()

			if event.is_action_pressed("place"):
				if not faction.attacker_list[listy].get_ref().injured:
					listx -= 1
					select_occupy = false
	#				occupying = true
					occupy()
					if selected.occupency - 1 > slot:
						listy = slot + 1
					else: 
						listy = 0
					selector()
		else:
			if occupying:
				if event.is_action_pressed("select_down"):
					if listy < selected.occupency - 1:
						listy += 1
						selector()
				elif event.is_action_pressed("select_up"):
					if listy > 0:
						listy -= 1
						selector()
				elif event.is_action_pressed("select_right"):
					get_node("build_upgrade/survivor_ui").show()
					slot = listy
					listy = 0
					listx += 1
					select_occupy = true
					selector()
				elif event.is_action_pressed("select_left"):
					listx -= 1
					listy = 0
					occupying = false
					selector()
				if event.is_action_pressed("place"):
					slot = listy
					listy = 0
					listx += 1
					select_occupy = true
					selector()
				if event.is_action_pressed("grenade"):
					slot = listy
					if selected.occupency - 1 > slot:
						listy = slot + 1
					else: 
						listy = 0
	#				occupying = true
#					occupy()
					player_occupy()
					listy = 0
					selector()
			else:
				if event.is_action_pressed("select_right"):
					if selected.occupency > 0:
						listx += 1
						occupying = true
						occupying()
						selector()
				elif event.is_action_pressed("select_left"):
					pass
				if event.is_action_pressed("select_down"):
					if upgrade_x >= level.events.event_list.size() - 1:
						upgrade_x = 0
					else:
						upgrade_x += 1
					selector()
				elif event.is_action_pressed("select_up"):
					if upgrade_x == 0:
						upgrade_x = level.events.event_list.size() - 1
					else:
						upgrade_x -= 1
					selector()
				if event.is_action_pressed("place"):
					if selected.occupency > 0:
						listx += 1
						occupying = true
						occupying()
						selector()
						
	elif upgrade_menu and faction.defence_list != []:
		if select_occupy:
			if event.is_action_pressed("select_down"):
				if listy < survivor_cards.size() - 1:
					listy += 1
					selector()
			elif event.is_action_pressed("select_up"):
				if listy > 0:
					listy -= 1
					selector()
			elif event.is_action_pressed("select_right"):
				pass
			elif event.is_action_pressed("select_left"):
				listx -= 1
				listy = 0
				select_occupy = false
				selector()
			if event.is_action_pressed("place"):
				if not faction.attacker_list[listy].get_ref().injured:
					listx -= 1
					select_occupy = false
	#				occupying = true
					occupy()
					occupying()
					if selected.occupency - 1 > slot:
						listy = slot + 1
					else: 
						listy = 0
					selector()
		else:
			if occupying:
				if event.is_action_pressed("select_down"):
					if listy < selected.occupency - 1:
						listy += 1
						selector()
				elif event.is_action_pressed("select_up"):
					if listy > 0:
						listy -= 1
						selector()
				elif event.is_action_pressed("select_right"):
					slot = listy
					listy = 0
					listx += 1
					select_occupy = true
					selector()
				elif event.is_action_pressed("select_left"):
					listx -= 1
					listy = 0
					occupying = false
					selector()
				if event.is_action_pressed("place"):
					slot = listy
					listy = 0
					listx += 1
					select_occupy = true
					selector()
			else:
				if event.is_action_pressed("select_right"):
					if selected.occupency > 0:
						listx += 1
						occupying = true
						occupying()
						selector()
				elif event.is_action_pressed("select_left"):
					pass
				if event.is_action_pressed("select_down"):
					if upgrade_x >= faction.defence_list.size() - 1:
						upgrade_x = 0
					else:
						upgrade_x += 1
					selector()
				elif event.is_action_pressed("select_up"):
					if upgrade_x == 0:
						upgrade_x = faction.defence_list.size() - 1
					else:
						upgrade_x -= 1
					selector()
				if event.is_action_pressed("place"):
					if selected.occupency > 0:
						listx += 1
						occupying = true
						occupying()
						selector()
						
				if event.is_action_pressed("grenade"):
					yes_no("destroy")
					
	elif inventory_menu or on_supply_run:
		if select_occupy:
			if right_list != []:
				if event.is_action_pressed("select_down"):
					if listy < right_list.size() - 1:
						listy += 1
						selector()
				elif event.is_action_pressed("select_up"):
					if listy > 0:
						listy -= 1
						selector()
				elif event.is_action_pressed("select_right"):
					pass
					
				if event.is_action_pressed("place"):
					equip()
					selector()
				if event.is_action_pressed("interact"):
					drop()
					if listy > 0:
						listy -= 1
					display()
					selector()
			if event.is_action_pressed("select_left"):
				listx -= 1
				listy = current_list
				select_occupy = false
				selector()
				
			if event.is_action_pressed("grenade"):
				listy = 0
				if on_supply_run:
					if inv_list == 3:
						inv_list = 0
					else:
						inv_list += 1
				elif inv_list == 2:
					inv_list = 0
				else:
					inv_list += 1
				display()
				selector()

		else:
			if event.is_action_pressed("select_right") or event.is_action_pressed("place"):
				listx += 1
				current_list = listy
				listy = 0
				select_occupy = true
				selector()
			elif event.is_action_pressed("select_left"):
				pass
			if event.is_action_pressed("select_down"):
				if faction.attacker_list != []:
					var size = faction.attacker_list.size()
					if listy >= size:
						listy = 0
					else:
						listy += 1
				selector()
			elif event.is_action_pressed("select_up"):
				if listy == 0:
					var size = faction.attacker_list.size()
					if faction.attacker_list != []:
						listy = size
				else:
					listy -= 1
				selector()
				
	if event.is_action_pressed("left") and not yes_no and not on_supply_run:
		if menu > 0:
			menu -= 1
#			if build_menu:
#				clear_column(current_list)
			menu()
	elif event.is_action_pressed("right") and not yes_no and not on_supply_run:
		if menu < 3:
			menu += 1
#			if build_menu:
#				clear_column(current_list)
			menu()
			
	if event.is_action_pressed("command"):
		if yes_no:
			x = 1
			no()
		else:
			close()
#		if place == true:
#			Build.queue_free()
#			selected.queue_free()
#			place = false
#			windows = false

func highlight(val):
	highlighting = val
	if not highlighting:
#		set_fixed_process(false)
		selected.get_node("body 1").set_modulate(Color(1,1,1))
#	else:
#		set_fixed_process(true)

func _fixed_process(delta):
	if highlighting:
		if highlight > highlight_total or highlight_reverse:
			highlight_reverse = true
			highlight -= delta
			if highlight < 1:
				highlight_reverse = false
		else:
			highlight += delta
		selected.get_node("body 1").set_modulate(Color(highlight,highlight,highlight))
		
	if building and build_menu:
		player.look(selected)
		player.raycast.set_rot(player.get_angle_to(selected.get_global_pos()) - 3.14159/2)
		player.flip_check()
		if right or left or up or down:
			scroll_speed_delay -= delta
			if scroll_speed_delay <= 0:
				scroll_speed -= delta
				if scroll_speed <= 0:
					scroll_speed = .05
					if right:
						get_node("follow").set_global_pos(Vector2(get_node("follow").get_global_pos().x + 20, get_node("follow").get_global_pos().y))
					if left:
						get_node("follow").set_global_pos(Vector2(get_node("follow").get_global_pos().x - 20, get_node("follow").get_global_pos().y))
					if up:
						get_node("follow").set_global_pos(Vector2(get_node("follow").get_global_pos().x, get_node("follow").get_global_pos().y  - 20))
					if down:
						get_node("follow").set_global_pos(Vector2(get_node("follow").get_global_pos().x, get_node("follow").get_global_pos().y  + 20))

		


		var follow_pos = get_node("follow").get_global_pos()
		var coords = level.get_node("TileMap").world_to_map(follow_pos)
		var revert = level.get_node("TileMap").map_to_world(coords)
		var tilesize = level.get_node("TileMap").get_cell_size()
		construction.set_global_pos(revert + Vector2(tilesize.x / 2 - (round((selected.size -1)/2) * 20), tilesize.y))
		construction.set_rot(0)
		selected.set_global_pos(revert + Vector2(tilesize.x / 2 - (round((selected.size -1)/2) * 20), tilesize.y))
		selected.set_rot(0)
	elif inventory_menu:
		get_node("follow").set_global_pos(selected.get_global_pos())
#		if select_occupy:
#			get_node("follow").set_global_pos(faction.attacker_list[current_list].get_ref().get_global_pos())
#		else:
#			get_node("follow").set_global_pos(faction.attacker_list[listy - 1].get_ref().get_global_pos())
#		selected.set_global_pos(get_node("follow/Camera2D").get_global_pos())
#		construction.set_global_pos(get_node("follow/Camera2D").get_global_pos())