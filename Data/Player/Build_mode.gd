extends Node2D
var deploy = preload("res://Deployables.tscn")
var allies = preload("res://Allies.tscn")
var icons = preload("res://Inventory_icons.tscn")
var build = preload("res://Buildings.tscn")

var construction
var selected

var pos

var supply_run = false
var select_party = false

var menu = 0

var upgrade_x = 0
var left_list = []
var slot = 0
var slots = []
var occupying = false
var select_occupy = false
var survivor_cards = []

var prevx = 0

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
var survivor_menu = false


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

func _ready():
	faction = get_parent()
	level = get_parent().get_parent()
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
	menu()
	set_process_input(true)
	set_fixed_process(true)

#	display()
#	display_column()
	selector()
	
func close():
	if !player:
		pass
	else:
		get_node("follow/Camera2D").clear_current()
		set_process_input(false)
		set_fixed_process(false)
		player.get_node("Camera2D").make_current()
		player.set_process_input(true)
		get_node("build_upgrade/upgrade_ui").hide()
		get_node("build_upgrade/survivor_ui").hide()
		get_node("build_upgrade/build_ui").hide()
		if level.map.get_parent() != null:
			level.map.get_parent().remove_child(level.map)
		player.windows = false
	remove_building()

func clear_(list):
	for items in list:
		items.call_deferred("queue_free")
	list.clear()

func display():
	get_node("build_upgrade/build_ui").set_global_pos(Vector2(50, get_viewport().get_rect().size.y - get_viewport().get_rect().size.y + 25))
	get_node("build_upgrade/upgrade_ui").set_global_pos(Vector2(50, get_viewport().get_rect().size.y - get_viewport().get_rect().size.y + 25))
	get_node("build_upgrade/survivor_ui").set_global_pos(Vector2(400, get_viewport().get_rect().size.y - get_viewport().get_rect().size.y + 25))
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
		
	number = 0
	
	clear_(survivor_cards)
	for npc in player.faction.attacker_list:
		var survivor_card = get_node("survivor_card").duplicate()
		survivor_card.set_pos(Vector2(get_node("build_upgrade/survivor_ui").get_pos().x, get_node("build_upgrade/survivor_ui").get_pos().y + (30 * number)))
		survivor_card.get_node("Label").set_text(npc.get_ref().name)
		survivor_card.get_node("Label1").set_text(npc.get_ref().job)
		survivor_cards.append(survivor_card)
		get_node("build_upgrade/survivor_ui").add_child(survivor_card)
		survivor_card.show()
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
#	
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

func selector():
	remove_building()
	if build_menu:
		if listx == 1:
			selected = hud_list[current_list][listy].duplicate()
			construction = selected.builder().duplicate()
			faction.add_child(selected)
			construction.structure = selected
			faction.add_child(construction)
			get_node("build_upgrade/build_ui/deploys/box9").set_pos(Vector2(get_node("build_upgrade/build_ui/Position2D").get_pos().x, get_node("build_upgrade/build_ui/Position2D").get_pos().y + (24 * listy)))
	#		highlight(true)
		else:
			get_node("build_upgrade/build_ui/deploys/box9").set_pos(Vector2(get_node("build_upgrade/build_ui/deploys/box0").get_pos().x, get_node("build_upgrade/build_ui/Position2D").get_pos().y + (24 * listy)))
	elif upgrade_menu:
		get_node("build_upgrade/survivor_ui").show()
		if select_occupy:
			get_node("build_upgrade/upgrade_ui/selector").set_global_pos(survivor_cards[listy].get_global_pos())
		else:
			if occupying:
				get_node("build_upgrade/upgrade_ui/selector").set_pos(slots[listy].get_pos())
			else:
				highlight(false)
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
	elif supply_run:
		get_node("build_upgrade/survivor_ui").show()
		if select_occupy:
			get_node("build_upgrade/upgrade_ui/selector").set_global_pos(survivor_cards[listy].get_global_pos())
		else:
			if occupying:
				get_node("build_upgrade/upgrade_ui/selector").set_pos(slots[listy].get_pos())
			else:
				highlight(false)
				selected = level.events.event_list[upgrade_x].get_ref()
				occupying()
				get_node("follow").set_global_pos(Vector2(level.events.event_list[upgrade_x].get_ref().get_global_pos().x, level.events.event_list[upgrade_x].get_ref().get_global_pos().y))
				get_node("build_upgrade/upgrade_ui/selector").set_pos(left_list[upgrade_x].get_pos())
				highlight(true)

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
	if upgrade_menu:
		highlight(false)
	if supply_run:
		highlight(false)
	if level.map.get_parent() != null:
		level.map.get_parent().remove_child(level.map)
	build_menu = false
	upgrade_menu = false
	survivor_menu = false
	get_node("build_upgrade/upgrade_ui").hide()
	get_node("build_upgrade/survivor_ui").hide()
	get_node("build_upgrade/build_ui").hide()
	current_list = 0
	listy = 0
	listx = 0
	building = false
	occupying = false
	select_occupy = false
	supply_run = false
	if menu == 0:
		build_menu = true
		display()
		display_column()
		get_node("build_upgrade/build_ui").show()

	elif menu == 1:
		upgrade_menu = true
		get_node("build_upgrade/upgrade_ui").show()
		get_node("build_upgrade/survivor_ui").show()
		remove_building()
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
#					slot_card.get_node("Label").set_text(selected.occupents[number].name)
		else:
			slot_card.get_node("Label").set_text("Open")
		get_node("build_upgrade/upgrade_ui").add_child(slot_card)
		slot_card.show()
		number += 1
	pass
func _input(event):
	if build_menu:
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
				if faction.points >= selected.cost:
					faction.points -= selected.cost
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
						
	elif upgrade_menu:
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
						
			
	if event.is_action_pressed("left"):
		if menu > 0:
			menu -= 1
#			if build_menu:
#				clear_column(current_list)
			menu()
	elif event.is_action_pressed("right"):
		if menu < 2:
			menu += 1
#			if build_menu:
#				clear_column(current_list)
			menu()
			
	if event.is_action_pressed("command"):
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

		
#		get_node("follow/Camera2D").set_global_pos(selected.get_global_pos())
		var follow_pos = get_node("follow").get_global_pos()
		var coords = level.get_node("TileMap").world_to_map(follow_pos)
		var revert = level.get_node("TileMap").map_to_world(coords)
		var tilesize = level.get_node("TileMap").get_cell_size()
		construction.set_pos(revert + Vector2(tilesize.x / 2 - (round((selected.size -1)/2) * 20), tilesize.y))
		construction.set_rot(0)
		selected.set_pos(revert + Vector2(tilesize.x / 2 - (round((selected.size -1)/2) * 20), tilesize.y))
		selected.set_rot(0)
