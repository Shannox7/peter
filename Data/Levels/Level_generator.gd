extends Node2D
#var zones = preload("res://Zones.tscn").instance()
var enemies = preload("res://Enemies.tscn").instance()
var faction
var enemy_faction
var Global
var loader
var area
var roads = []
var road_sign = ''
var index

var loaded_enemies = []

var nodes = []

var camera_limit

var chase_list = []
var vector
var old_zone = null

var limit = 50
var time = 5
var current_door
var Base = null
func _fixed_process(delta):
	if loaded_enemies.size()-1 < limit:
		time -= delta
		if time <= 0:
			time = 5
			enemies_over_time()

func enemies_over_time():
#	loader.start()
#	loader.queue_resource("res://Enemies.tscn")
#	var resource = loader.get_resource("res://Enemies.tscn").instance()
	var new_enemy = enemies.get_node("Zombie_screamer").duplicate()
#	new_enemy.get_parent().remove_child(new_enemy)
	enemy_faction.call_deferred("add_child", new_enemy)
	new_enemy.set_global_pos(Vector2(-1000, 1000))
	new_enemy.call_deferred("start", false)

func load_enemies():
#	set_fixed_process(true)
	var number = -1
	for enemy in range(loaded_enemies.size(), limit):
#		print(enemy)
		loader.start()
		loader.queue_resource("res://Enemies.tscn")
		var resource = loader.get_resource("res://Enemies.tscn").instance()
		var new_enemy = resource.get_node("Zombie_screamer")
#		var new_enemy = enemies.get_node("Zombie_screamer").duplicate()
#		call_deferred("print",new_enemy.get_name())
		new_enemy.get_parent().remove_child(new_enemy)
		enemy_faction.call_deferred("add_child", new_enemy)
		new_enemy.set_global_pos(Vector2(-1000, 1000))
		new_enemy.call_deferred("start", false)
		new_enemy.set_z(number)
		new_enemy.hide()
		number -= 1
#		new_enemy.create()
#		loaded_enemies.call_deferred("append", new_enemy.myself)
#		call_deferred("print", loaded_enemies.back().get_ref().get_name())
#		resource.free()
		
func spawn(numb):
	var number = nodes.find(faction.player_list.front().zone.get_parent())
	if number + 3 > nodes.size() or number - 3 < 0:
		numb *= 2

	if number + 3 < nodes.size():
		if nodes[number + 3].is_road:
			nodes[number + 2].call_deferred("spawn", numb/2)
		else:
			nodes[number + 3].call_deferred("spawn", numb/2)

	if number - 3 > 0:
		if nodes[number - 3].is_road:
			nodes[number - 2].call_deferred("spawn", numb/2)
		else:
			nodes[number - 3].call_deferred("spawn", numb/2)
	pass

func chased():
	current_door.get_parent().chased = true
	current_door.chased()

#func performance():

func start(where):
	var number
	if where == null:
		number = nodes.find(Base)
	else:
		number = nodes.find(where)
	print(number)
	for node in nodes:
		if nodes.find(node) > number + 2 or nodes.find(node) < number - 2 and nodes.find(node) != number:
			if node.get_parent()!= null:
				node.get_parent().call_deferred("remove_child", node)
		else:
			if node.get_parent() == null:
				call_deferred("add_child", node)
				node.call_deferred("reinforce")
		if nodes.find(node) <= number + 2 and nodes.find(node) >= number - 2:
			if node.is_road:
				pass
			else:
				node.call_deferred("reinforce")

func reinforce(new_zone):
	pass
#	if old_zone == null:
#		old_zone = faction.player_list.front().zone.get_parent()
#	if new_zone == old_zone:
#		pass
#	else:
#		var si
#		if new_zone.get_global_pos().x > old_zone.get_global_pos().x:
#			si = 1
#		else:
#			si = -1
#		var number = nodes.find(new_zone)
#		if number + (2 * si) <= nodes.size() -1 and number + (2 * si) >= 0:
#			if nodes[number + (2 * si)].is_road :
#				if nodes[number + (2 *si)].get_parent() == null:
#					call_deferred("add_child", nodes[number + (2 *si)])
#			else:
#				nodes[number + (2 *si)].call_deferred("reinforce")
#				
#
#		if number - (2 * si) < nodes.size() -1 and number - (2 * si) > 0:
#			if nodes[number - (2 *si)].get_parent() != null:
#				nodes[number - (2 *si)].call_deferred("free_enemies")
#				nodes[number - (2 *si)].get_parent().call_deferred("remove_child")
#		if number - (3 * si) <= nodes.size() -1 and number - (3 * si) >= 0:
#			if nodes[number - (3 *si)].get_parent() != null:
#				nodes[number - (3 *si)].call_deferred("free_enemies")
#				nodes[number - (3 *si)].get_parent().call_deferred("remove_child")
#
#		old_zone = new_zone

#func reinforce(where):
#	for enemy in enemy_faction.attacker_list:
#		enemy.call_deferred("check_nec")
#	var number = nodes.find(where)
#	if number + 3 < nodes.size():
#		if nodes[number + 3].is_road:
#			nodes[number + 2].call_deferred("reinforce")
#		else:
#			nodes[number + 3].call_deferred("reinforce")
#
#	if number - 3 > 0:
#		if nodes[number - 3].is_road:
#			nodes[number - 2].call_deferred("reinforce")
#		else:
#			nodes[number - 3].call_deferred("reinforce")
func _ready():
	faction = get_node("Faction")
	enemy_faction = get_node("Enemy_faction")
#	call_deferred("load_enemies")
	Global = get_node("/root/Global")
	if Global.player.get_parent() != null:
		Global.player.get_parent().remove_child(Global.player)
	Global.player.set_global_pos(get_node("player_pos").get_global_pos())
	Global.player.faction = faction
	Global.player.level = self
	faction.call_deferred("add_child", Global.player)
	Global.Base = self
	Global.player.get_node("Camera2D").set_limit(2, camera_limit)
	Global.player.get_node("Camera2D").set_limit(0, 0)
	Global.player.in_building = false
	pass
	
func generate_level(type, size, xy, base, base_number, base_numb):
	loader.start()
	loader.queue_resource("res://Zones.tscn")
	var zones = loader.get_resource("res://Zones.tscn").instance()
	var road_signs
	vector = xy
	if xy == "x":
		index = 1
		road_signs = area.road_signsy
	else:
		index = 0
		road_signs = area.road_signsx
	
	var last_zone = null
	var zone_dup
	for number in range(size):
		zone_dup = zones.get_node(str(type) +  "/Road/road" + str(round(rand_range(0, zones.get_node(str(type) +  "/Road").get_children().size() - 1)))).duplicate()
#		zone_dup = zones.duplicate()
		roads.append(zone_dup)
		nodes.append(zone_dup)
		call_deferred("add_child", zone_dup)
		if last_zone != null:
			zone_dup.set_global_pos(last_zone.get_node("end").get_global_pos())
#		zone_dup.call_deferred("add_foliage")
		last_zone = zone_dup
		if number < size - 1:
			for numb in range(3):
				if base != null and number == base_number and numb == base_numb:
					zone_dup = base.duplicate()
					Base = zone_dup
					zone_dup.set_global_pos(last_zone.get_node("end").get_global_pos())
					area.start = zone_dup.get_node("player_pos").get_global_pos()
				else:
					zone_dup = zones.get_node(str(type) +  "/Street/block" + str(round(rand_range(0, zones.get_node(str(type) +  "/Street").get_children().size() - 1)))).duplicate()
#					zone_dup = zones.get_node(str(type) +  "/Street/block" + str(round(rand_range(0, zones.get_node(str(type) +  "/Street").get_children().size() - 1)))).duplicate()
				nodes.append(zone_dup)
				call_deferred("add_child", zone_dup)

				if last_zone != null:
					zone_dup.set_global_pos(last_zone.get_node("end").get_global_pos())
#				zone_dup.call_deferred("add_foliage")
				last_zone = zone_dup
	camera_limit = last_zone.get_node("end").get_global_pos().x
	call_deferred("add_scenery")

func add_scenery():
	for node in nodes:
		node.call_deferred("add_foliage")
func attach_roads(levels):
	var number = 0
	for road in roads:
		road.road = levels[number]
		road.road_sign = levels[number].road_sign
		number += 1