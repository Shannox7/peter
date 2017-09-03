extends Control
var deploy = preload("res://Deployables.tscn")
var allies = preload("res://Allies.tscn")
var icons = preload("res://Inventory_icons.tscn")
var build = preload("res://Buildings.tscn")

var bullet_list = []

var prevx = 0
var listx = 0
var hud_list = [[],[]]
var hud_display_list = [[],[]]
var player

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
func _ready():
	player = get_parent().get_parent()
	set_process_input(true)
	infantryd = icons.instance().get_node("Recruit/Infantry")
	mined = icons.instance().get_node("Deployables/Mine")
	turretd = icons.instance().get_node("Deployables/Turret")
	walld = icons.instance().get_node("Buildables/steel_wall")
	sandbag_nestd = icons.instance().get_node("Buildables/sandbags")
	
	sandbag_nest = build.instance().get_node(player.faction.faction + "/Defence/sandbag_bunker")
	foxhole = build.instance().get_node(player.faction.faction + "/Defence/foxhole")
	infantry = allies.instance().get_node("Infantry")
	engineer = allies.instance().get_node("Engineer")
	turret = deploy.instance().get_node("machinegun_turret")
	mine = deploy.instance().get_node("mine")
	wall = build.instance().get_node(player.faction.faction + "/Barricades/steel_wall")
	tall_wall = build.instance().get_node(player.faction.faction + "/Barricades/tall_steel_wall")
#	building_build = build.instance().get_node("Build")
	deploy_build = deploy.instance().get_node("Build")
	barracks = build.instance().get_node(player.faction.faction + "/Spawn_buildings/infantry")
	war_factory = build.instance().get_node(player.faction.faction + "/Spawn_buildings/war_factory")
	hud_list = [[infantry, engineer],[turret.duplicate()],[wall, tall_wall, sandbag_nest, foxhole, barracks, war_factory], [mine]]
	hud_display_list = [[infantryd, infantryd.duplicate()],[turretd], [walld, walld.duplicate(), sandbag_nestd, walld.duplicate(), mined.duplicate(), turretd.duplicate()], [mined]]

	display()
	display_column()
	pass
#	hud_list
func shoot(player):
	pass
#	bullet_list.back().unlock()
#	bullet_list.pop_back()
	
func clear_ammo():
	for bullet in range(bullet_list.size()):
		bullet_list.back().unlock()
		bullet_list.pop_back()
		
func ammo(player):
	var numbery = 0
	var numberx = 0
	for bullet in range(player.bullet_list.size()):
		if numberx == 50:
			numbery += 10
			numberx = 0
		var new_bullet = icons.instance().get_node("Ammo/bullet").duplicate()
		new_bullet.set_pos(Vector2(get_node("ammo_position").get_pos().x + new_bullet.size * numberx, get_node("ammo_position").get_pos().y + numbery))
		bullet_list.append(new_bullet)
		call_deferred("deferred", new_bullet)
		numberx +=1

func deferred(defer):
	add_child(defer)

func update_hud():
	var scale = 100
	get_node("Points").set_text("Points: " + str(player.faction.points))
	get_node("Label 2").set_text("Ammo: " + str(player.current_ammo) + "/" + str(player.total_ammo))
func display():
	var number = 0
	for lists in hud_display_list:
		lists[0].set_pos(get_node("deploys").get_pos() + get_node("deploys/box" + str(number)).get_pos())
		if lists[0].get_parent() != null:
			lists[0].get_parent().remove_child(lists[0])
		add_child(lists[0])
		number += 1

func display_column():
	var number = 0
	get_node("deploys/box" + str(prevx) + "/Label").show()
	get_node("deploys/box" + str(listx) + "/Label").hide()
	get_node("deploys/box" + str(prevx) + "/description").set_text("")
	get_node("deploys/box" + str(listx) + "/description").set_text(str(hud_list[listx][0].name) + "\n" + "Cost: " + str(hud_list[listx][0].cost))
	for items in hud_display_list[listx]:
		items.set_pos(Vector2(get_node("deploys").get_pos().x + get_node("deploys/box" + str(listx)).get_pos().x  + (24 * number), get_node("deploys").get_pos().y + get_node("deploys/box" + str(listx)).get_pos().y))
		if items.get_parent() != null:
			items.get_parent().remove_child(items)
		add_child(items)
		number += 1

func clear_column(x):
	var number = 1
	for items in hud_display_list[x]:
		items.get_parent().remove_child(items)
		number += 1
func selector():
#	print("deploys/box" + str(listx))
	get_node("deploys/box9").set_pos(get_node("deploys/box" + str(listx)).get_pos())
#	hud_list[listx][0]
#if player.placing == false and player.inventory == false:
func _input(event):
	if player.windows == false:
		prevx = listx
		if event.is_action_pressed("select_up"):
			clear_column(listx)
			if listx == hud_display_list.size() - 1:
				listx = 0
			else:
				listx += 1
	#			print(listx)
		elif event.is_action_pressed("select_down"):
			clear_column(listx)
			if listx == 0:
				listx == hud_display_list.size() - 1
			else:
				listx -= 1
		elif event.is_action_pressed("select_right"):
			if hud_list[listx].size() > 1: 
				hud_display_list[listx].append(hud_display_list[listx].front())
				hud_display_list[listx].pop_front()
				hud_list[listx].append(hud_list[listx].front())
				hud_list[listx].pop_front()
		elif event.is_action_pressed("select_left"):
			if hud_list[listx].size() > 1: 
				hud_display_list[listx].push_front(hud_display_list[listx].back())
				hud_display_list[listx].pop_back()
				hud_list[listx].push_front(hud_list[listx].back())
				hud_list[listx].pop_back()
		selector()
		display_column()
		display()
		if event.is_action_pressed("place") and player.place == false:
			if player.faction.points >= hud_list[listx][0].cost:
				player.windows = true
				if listx == 0:
					player.recruit(hud_list[listx][0].duplicate())
				elif listx == 1:
					player.building(hud_list[listx][0].duplicate(), hud_list[listx][0].builder().duplicate())
				elif listx == 2:
					player.building(hud_list[listx][0].duplicate(), hud_list[listx][0].builder().duplicate())
				elif listx == 3:
					player.deploy(hud_list[listx][0].duplicate(), deploy_build.duplicate())
			else:
				player.comment("I cant afford this!")