extends Node2D

var buildings = preload("res://buildings.tscn").instance()
var guns = preload("res://Guns.tscn")
var armour = preload("res://armour.tscn")
var survivor = preload("res://Allies.tscn").instance()
var enemies = preload("res://Enemies.tscn").instance()
var resource = preload("res://resource.tscn").instance()
var darkness = preload("res://darkness.tscn").instance()
var foliage = preload("res://foliage.tscn").instance()

var enemy_reinforce = 0
var enemy_faction
var faction

var map_coords = []

var loaded = false

var party

var enemy_number = 0
var chase_list = []

var chased = false
var lockdown = false

var current_door = null
var is_road = false

var time = .5

var door_colour = Color(1,1,1)
func chased():
	chased = true
	if current_door != null:
		current_door.chased()
	else:
		get_node("return").chased()
	current_door = null

func shuffleList(list):
	var shuffledList = [] 
	var indexList = range(list.size())
	for i in range(list.size()):
		var x = randi()%indexList.size()
		shuffledList.append(list[indexList[x]])
		indexList.remove(x)
		return shuffledList

func loot():
	randomize()
	var loot_spawn = get_node("loot").get_children()
	shuffleList(loot_spawn)
	
	var loot_chance = 5
	var number = 0
	for spawn in get_node("loot").get_children():
		if number == loot_chance:
			break
		else:
			var loot = resource.loot(self)
			if loot != null:
				get_node("loot_node").call_deferred("add_child", loot)
				loot.call_deferred("set_global_pos", spawn.get_global_pos())
		number += 1

func add_foliage():
	for cells in get_node("Outside/background").get_used_cells():
		if get_node("Outside/background").get_cell(cells.x, cells.y) == 2:
			var coords = get_node("Outside/background").map_to_world(cells)
			var fol = foliage.get_children()[round(rand_range(0, foliage.get_children().size() -1))].duplicate()
			fol.set_global_pos( Vector2(coords.x + 10, coords.y - 10))
			fol.set_z(get_node("Outside/background").get_z())
			get_node("foliage").call_deferred("add_child", fol)

	for cells in get_node("Outside/walk").get_used_cells():
		if get_node("Outside/walk").get_cell(cells.x, cells.y) == 2:
			var coords = get_node("Outside/walk").map_to_world(cells)
			var fol = foliage.get_children()[round(rand_range(0, foliage.get_children().size() -1))].duplicate()
			fol.set_global_pos(Vector2(coords.x + 10, 0))
			fol.set_z(get_node("Outside/walk").get_z())
			get_node("foliage").call_deferred("add_child", fol)

func free_enemies():
	set_fixed_process(false)
	for enemy in get_node("Area2D").get_overlapping_bodies():
		if enemy.get_parent().AI and !enemy.get_parent().chase:
#			enemy.get_parent().set_global_pos(Vector2(-1000, 1000))
#			enemy.get_parent().free_up()
#			enemy.get_parent().call_deferred("start", false)
#			enemy.get_parent().home_zone.get_ref().enemy_number -= 1
			enemy.call_deferred("queue_free")
			pass

func reinforce():
	if enemy_reinforce > enemy_number:
		if not is_fixed_processing():
			call_deferred("set_fixed_process", true)
	#	var number= 0
	#	for spawn in range(enemy_reinforce - enemy_number):
		var zombie = enemies.get_node("Zombie_screamer").duplicate()
		enemy_faction.call_deferred("add_child", zombie)
#	#	get_parent().loaded_enemies.append(zombie.myself)
		
#		var zombie = null
#		if get_parent().loaded_enemies == []:
#			zombie = enemies.get_node("Zombie_screamer").duplicate()
#			enemy_faction.call_deferred("add_child", zombie)
#			get_parent().loaded_enemies.append(zombie.myself)
#		else:

#		if get_parent().loaded_enemies.front() == null:
#			get_parent().loaded_enemies.pop_front()
#		elif !get_parent().loaded_enemies.front().get_ref():
#			get_parent().loaded_enemies.pop_front()
#		else:
#		var zombie = get_parent().loaded_enemies.front().get_ref()
#		if zombie != null:
#			if not zombie.get_ref().free:
#				zombie.get_ref().free_up()
		var spawn = get_node("spawns").get_children()[round(rand_range( 0, get_node("spawns").get_children().size()-1))]
		zombie.call_deferred("set_global_pos", spawn.get_global_pos())
#		zombie.set_z(spawn.get_z() - 1)
		spawn.call_deferred("spawn", zombie)
		zombie.home_zone = weakref(self)
		zombie.zone = get_node("Area2D")
#		zombie.call_deferred("create_new")
		zombie.start(true)
		enemy_number += 1
#		get_parent().loaded_enemies.append(get_parent().loaded_enemies.front())
#		get_parent().loaded_enemies.pop_front()

func initialize():
	faction = get_parent().get_node("Faction")
	enemy_faction = get_parent().get_node("Enemy_faction")
	Global = get_node("/root/Global")
	get_node("VisibilityNotifier2D").connect("enter_viewport", self, "get_ready")
	get_node("VisibilityNotifier2D").connect("exit_viewport", self, "remove_self")
	enemy_reinforce = round(rand_range(5, 10))
	loot()

func get_ready(view):
	call_deferred("reinforce")
	pass

func remove_self(view):
	call_deferred("free_enemies")
	
func spawn(attackers):
	var number= 0
	for spawn in range(attackers):
		var zombie = enemies.get_node("Zombie_movement").duplicate()
		zombie.home_zone = weakref(self)
		enemy_faction.call_deferred("add_child", zombie)
		if get_node("Area2D/spawns").get_children().size() - 1 < number:
			number = 0
		zombie.set_global_pos(get_node("Area2D/spawns").get_children()[number].get_global_pos())
		number += 1
#		enemy_number += 1
		for player in get_parent().faction.player_list:
			zombie.target_list.append(player.myself)
		zombie.level = get_parent()
		zombie.call_deferred("chase")
	pass

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

func _fixed_process(delta):
	time -= delta
	if time <= 0:
		if enemy_reinforce > enemy_number:
			time = .5
			call_deferred("reinforce")
		else:
			set_fixed_process(false)

