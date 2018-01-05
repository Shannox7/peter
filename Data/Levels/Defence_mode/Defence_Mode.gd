extends Node2D
#var fact = preload("res://Faction.tscn").instance()

var Global

#var gamepad

var enemies = preload("res://Enemies.tscn").instance()
#var r = preload("res://Report.tscn").instance()
var foliage = preload("res://foliage.tscn").instance()

var report

var faction
var enemy_faction

var set = false

var loaded_enemies = []

var round_end = true
var wait_time = 120
var total_wait_time = 120
var level = 0

var chase_list = []

var total_enemy_number = 0
var enemy_number = 0
var enemy_reinforce = 30
var limit  = 10
var z_number = -1

var spawning = false
var spawn_time = 1
var total_spawn_time = 1
var load_time = 1
func add_foliage():
	for cells in get_node("Outside/background").get_used_cells():
		if get_node("Outside/background").get_cell(cells.x, cells.y) == 2:
			var coords = get_node("Outside/background").map_to_world(cells)
			var fol = foliage.get_children()[round(rand_range(0, foliage.get_children().size() -1))].duplicate()
			fol.set_z(get_node("Outside/background").get_z() + 1)
			get_node("foliage").add_child(fol)
			fol.set_global_pos(Vector2(coords.x + 10, coords.y - 10))

	for cells in get_node("Outside/walk").get_used_cells():
		if get_node("Outside/walk").get_cell(cells.x, cells.y) == 2:
			var coords = get_node("Outside/walk").map_to_world(cells)
			var fol = foliage.get_children()[round(rand_range(0, foliage.get_children().size() -1))].duplicate()
			fol.set_z(get_node("Outside/walk").get_z())
			get_node("foliage").add_child(fol)
			fol.set_global_pos(Vector2(coords.x + 10, coords.y - 10))

func _ready():
	if set == false:
		set = true
		call_deferred("add_foliage")
		get_node("CanvasLayer/Control").set_pos(Vector2(get_viewport_rect().size.x/2, 20))
		get_node("CanvasLayer/Control/Label").set_text("Level: " + str(level))
		Global = get_node("/root/Global")
		faction = get_node("Faction")
		enemy_faction = get_node("Enemy_faction")
#		Global.player.get_node("Camera2D").set_limit(2, 2000)
#		call_deferred("load_enemies")
		
#		report = r.duplicate()
#		add_child(report)
#		report.get_node("report/report_ui").set_global_pos(Vector2(get_viewport().get_rect().size.x/2, get_viewport().get_rect().size.y - get_viewport().get_rect().size.y + 25))
		

#		for number in range(7):
#			var AK = guns.instance().get_node("Soldier_guns/AK47").duplicate()
#			AK.set_global_pos(get_node("gun_spawn").get_global_pos())
#			call_deferred("add_child", AK)
#			AK.call_deferred("spawn")
#	else:
#		var seperate = 0

	var number = 0
	var hud_pos = 0
	for p in range(2):
		var p = Global.player.duplicate()
		faction.call_deferred("add_child", p)
		p.joy = number
		p.pl = str(number)
		p.set_global_pos(get_node("player_pos").get_global_pos())
		p.player_hud_pos = hud_pos
		for act in InputMap.get_actions():
			if InputMap.get_action_list(act) != []:
				if InputMap.get_action_list(act).size() > 1:
					InputMap.add_action(str(number) + str(act))
					InputMap.action_add_event(str(number) + str(act), InputMap.get_action_list(act)[number])
		p.faction = faction
		p.level = self
		number += 1
		hud_pos += get_viewport_rect().size.x - 400
	call_deferred("set_camera")

#	Global.player.get_node("Camera2D").
	Global.Base = self
#	call_deferred("start_round")
	set_fixed_process(true)
	
func set_camera():
	var camera = load("res://Camera.tscn").instance()
	if camera.get_parent() != null:
		camera.get_parent().remove_child(camera)
	camera.set_global_pos(faction.player_list.front().get_global_pos())
	faction.add_child(camera)
	camera.reset_smoothing()
	
func spawn():
	var zombie
#	if loaded_enemies != []:
#		zombie = loaded_enemies.back()
#	else:
	zombie = enemies.get_node("Zombie_movement").duplicate()
	enemy_faction.call_deferred("add_child", zombie)
#	zombie.set_global_pos(get_node("enemy_start/enemy_start1").get_global_pos())
	zombie.home_zone = weakref(self)
	zombie.zone = get_node("Area2D")
	zombie.level = self
	var spawn = get_node("spawns").get_children()[round(rand_range( 0, get_node("spawns").get_children().size()-1))]
	zombie.set_global_pos(spawn.get_global_pos())
#	zombie.show()
#	zombie.set_z(spawn.get_z() - 1)
#		spawn.call_deferred("spawn", zombie)
#	zombie.set_z(z_number)
	zombie.call_deferred("start", true)
	zombie.call_deferred("track", faction.player_list.back().get_node("body"))
	zombie.call_deferred("chase")
	enemy_number += 1
	total_enemy_number += 1
#	if loaded_enemies != []:
#		loaded_enemies.pop_back()
#	z_number -= 1
#	if z_number <= -100:
#		z_number = -1
func start_round():
	for number in range(enemy_reinforce + level):
		var zombie
		if loaded_enemies != []:
			zombie = loaded_enemies.back()
		else:
			zombie = enemies.get_node("Zombie_movement").duplicate()
			enemy_faction.call_deferred("add_child", zombie)
	#	zombie.set_global_pos(get_node("enemy_start/enemy_start1").get_global_pos())
		zombie.home_zone = weakref(self)
		zombie.zone = get_node("Area2D")
		zombie.level = self
		var spawn = get_node("spawns").get_children()[round(rand_range( 0, get_node("spawns").get_children().size()-1))]
		zombie.set_global_pos(spawn.get_global_pos())
	#	zombie.set_z(spawn.get_z() - 1)
#		spawn.call_deferred("spawn", zombie)
		
		zombie.call_deferred("start", true)
		zombie.call_deferred("track", Global.player.get_node("body"))
		zombie.call_deferred("chase")
		zombie.show()
		enemy_number += 1
		total_enemy_number += 1
		loaded_enemies.pop_back()

func level():
	get_node("CanvasLayer/Control/timer").set_text("")
	level += 1
	enemy_number = 0
	enemy_reinforce += (10 * level)
	get_node("CanvasLayer/Control/Label").set_text("Level: " + str(level))
	pass

func load_enemies():
	for number in range(50):
		var zombie = enemies.get_node("Zombie_movement").duplicate()
		loaded_enemies.append(zombie)
		enemy_faction.call_deferred("add_child", zombie)
		zombie.call_deferred("start", false)
		zombie.hide()
#	print(loaded_enemies)
	pass

func _fixed_process(delta):
	if round_end:
#		load_time -= delta
#		if load_time <= 0:
#			load_time = 1
#			call_deferred("load_enemies")
		wait_time -= delta
		get_node("CanvasLayer/Control/timer").set_text("Next level in " + str(round(wait_time)))
		if wait_time <= 0:
			wait_time = total_wait_time
			level()
			spawning = true
#			start_round()
			round_end = false
	else:
		get_node("CanvasLayer/Control/timer").set_text("Enemies remaining: " + str(enemy_reinforce - (total_enemy_number - enemy_number)))

	if spawning:
		spawn_time -= delta
		if spawn_time <= 0 and total_enemy_number < enemy_reinforce and enemy_number < limit:
			spawn_time = total_spawn_time
			spawn()
		elif total_enemy_number >= enemy_reinforce:
			spawning = false
			
	elif enemy_number <= 0:
		total_enemy_number = 0
		round_end = true
		
	