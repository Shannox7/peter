extends Node2D
#var Player = preload("res://Peter.tscn").instance()
#var enemies = preload("res://Enemies.tscn").instance()
#var allies =  preload("res://Allies.tscn").instance()
#var squad = preload("res://Squad.tscn").instance()
#var passive = preload("res://Passives.tscn").instance()
#var guns = preload("res://Guns.tscn").instance()
#var armour = preload("res://armour.tscn").instance()
var passive_list = []
var enemy_list = []
var ally_list = []
var ally_engineer_list = []
var passive_spawnpoint_list = []
var enemy_spawnpoint_list = []
var displaylist = []

var objective_list = []
var gunpickup
var gunpickup1
var gunpickup2
var current_ammo = 0
var total_ammo = 0
var total_health = 0
var current_health = 0
#guns
var flak_jacket
var combat_helmet
var camera
var M14
var Pistol
var Blaster
var enemy_spawn_max = 0
var ally_spawn_max = 0
var enemy_spawn = 0
var ally_spawn = 0
var enemy_time = 1
var ally_time = 1
var timer
var playername
var bullet_list = []
var HUD
var ally_player_list = []
var enemy_player_list = []
var ally_defence_list = []
var enemy_defence_list
var ally_build_list = []
var enemy_build_list = []
func _ready():
	objective_list.append(get_node("defence_zone"))
	objective_list.append(get_node("defence_zone 2"))
	objective_list.append(get_node("defence_zone 3"))
	objective_list.append(get_node("defence_zone 4"))
	get_node("defence_zone").set_controlled("allies")
	get_node("defence_zone 4").set_controlled("enemies")
	get_node("enemy_flood_wait").connect("timeout", self, "enemy_start_spawn")
	get_node("enemy_Timer").connect("timeout", self, "enemy_flood_spawn")
	get_node("enemy_Timer").set_wait_time(enemy_time)
	get_node("enemy_Timer").start()
	enemy_spawnpoint_list.append(get_node("spawnpoint"))
	get_node("ally_flood_wait").connect("timeout", self, "ally_start_spawn")
	get_node("ally_Timer").connect("timeout", self, "ally_flood_spawn")
	get_node("ally_Timer").set_wait_time(ally_time)
	get_node("ally_Timer").start()
	camera = get_node("Camera2D")
	var e = enemies.instance()
	var p = passive.instance()
	var gi = guns.instance()
	var p1 = Player.instance()
	M14 = gi.get_node("Tier_1/M14").duplicate()
	Pistol = gi.get_node("Pistol").duplicate()
	Blaster = gi.get_node("Blaster").duplicate()
	flak_jacket = armour.instance().get_node("Tier_1/body/flakjacket").duplicate()
	combat_helmet = armour.instance().get_node("Tier_1/head/combathelmet").duplicate()
	call_deferred("start_equip", get_node("Movement"))
#	set_fixed_process(true)

func spawn_squad(spawn):
	var s = squad.instance().duplicate()
	add_child(s)
	s.spawn_squad()
	
func points(side, points):
	if side == "ally":
		for players in ally_player_list:
			players.points += points
			players.update_hud()
	if side == "enemy":
		pass
#		for players in enemy_player_list:
#			players.points += points
func spawn_armour(spawn):
	var dup = flak_jacket.duplicate()
	dup.set_pos(spawn.get_pos())
	add_child(dup)
	dup.unlock()
	var dup1 = combat_helmet.duplicate()
	dup1.set_pos(spawn.get_pos())
	add_child(dup1)
	dup1.unlock()
func spawn_gun2(spawn):
	var dup = guns.instance().get_node("Tier_1/Shotgun").duplicate()
	dup.generate("Tier_1")
	dup.start()
	dup.set_pos(spawn.get_pos())
	add_child(dup)
	dup.unlock()
func spawn_gun(spawn):
	var dup2 = guns.instance().get_node("Tier_1/Gatling").duplicate()
	dup2.start()
	dup2.generate("Tier_1")
#	print (dup.accuracy)
	dup2.set_pos(spawn.get_pos())
	add_child(dup2)
	dup2.unlock()
#	dup.unlock()
	
func start_equip(player):
	var Uzi = guns.instance().get_node("Tier_1/M14").duplicate()
	var Unicorn = guns.instance().get_node("Unicorn").duplicate()
	var dup = Uzi.duplicate()
	dup.generate("Tier_1")
	dup.start()
	player.equip(dup, true, "primaryGun")

func enemy_flood_spawn():
	e = enemies.instance()
	var Uzi = guns.instance().get_node("Tier_1/M14").duplicate()
	var enemy = e.get_node("Zombie_movement").duplicate()
	if enemy_spawn > 0 and enemy_list.size() < enemy_spawn_max:
		var dup = Uzi
		var hold_order = 1

		enemy_list.append(enemy)
#		if enemy_list != []:
#		for e in enemy_list:
#			enemy.add_collision_exception_with(e)
#			print (e)
#			enemy.add_collision_exception_with(e)

		enemy.set_pos(get_node("spawnpoint1").get_global_pos())
		dup.generate("Tier_1")
		self.add_child(enemy)
		enemy.side("enemies")
		enemy.equip(dup, false, "primaryGun")
		enemy.hold_order("add")
		dup.start()
#		enemies.track(get_node("Movement/Player"))
		enemy_spawn -= 1
	if enemy_spawn == 0:
		get_node("enemy_Timer").stop()
		get_node("enemy_flood_wait").set_wait_time(5)
		get_node("enemy_flood_wait").start()

func ally_flood_spawn():
	var a = allies.instance()
	var ally = a.get_node("Infantry").duplicate()
	if ally_spawn > 0 and ally_list.size() < ally_spawn_max:
		ally_list.append(ally)
#		var listrange = ally_list.size()
		var dup = M14.duplicate()
#		if enemy_list != []:
#		for a in ally_list:
#			ally.call_deferred("add_collision_exception_with", a)
#			ally.add_collision_exception_with(get_node("Movement"))
#			listrange -= 1
		ally.set_pos(get_node("spawnpoint").get_global_pos())
		dup.generate("Tier_1")
		ally.equip(dup)
		self.add_child(ally)
		dup.start()
#		enemies.track(get_node("Movement/Player"))
		ally_spawn -= 1
	if ally_spawn == 0:
		get_node("ally_Timer").stop()
		get_node("ally_flood_wait").set_wait_time(5)
		get_node("ally_flood_wait").start()
		
func enemy_start_spawn():
	enemy_spawn = 5
	get_node("enemy_Timer").start()
	
func ally_start_spawn():
	ally_spawn = 5
	get_node("ally_Timer").start()

func passive_spawn(spawn):
	var spawnpoint_range = passive_spawnpoint_list.size() - 1
#	for spawnpoint in enemy_spawnpoint_list:
	for passive in spawn:
		passive.set_pos(passive_spawnpoint_list[spawnpoint_range].get_global_pos())
#		enemy.get_parent().remove_child(enemy)
		self.add_child(passive)
#		passive.add_collision_exception_with(passive_list[0])
#		passive.add_collision_exception_with(passive_list[1])
#		passive.add_collision_exception_with(passive_list[2])
#		passive.add_collision_exception_with(passive_list[3])
#		passive.add_collision_exception_with(passive_list[4])
#		if spawnpoint_range == 0:
#			spawnpoint_range = enemy_spawnpoint_list.size() - 1
		spawnpoint_range -= 1

#func _fixed_process(delta):
#	get_node("Camera2D").set_pos(get_node("Movement").get_pos())
#	if get_parent().get_rect().size != Vector2(1024, 600):
#	get_node("Movement/HUD/Player1").set_global_pos(Vector2(get_parent().get_rect().size.x - get_parent().get_rect().size.x + 50, get_parent().get_rect().size.y - 75))