extends Node2D
var woop
var Player = preload("res://Peter.tscn")
var enemies = preload("res://Enemies.tscn")
var e
var passive = preload("res://Passives.tscn")
var guns = preload("res://Guns.tscn")
var armour = preload("res://armour.tscn")
var passive_list = []
var enemy_list = []
var passive_spawnpoint_list = []
var enemy_spawnpoint_list = []
var displaylist = []
var boxdisplay = []
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
var flood_spawn = 5
var timer
var playername
var health_bar_list = []
var bullet_list = []
var HUD
func _ready():
#	passive_spawnpoint_list.append(.get_node("passive_spawnpoint"))
#	passive_spawnpoint_list.append(.get_node("passive_spawnpoint1"))
#	passive_spawnpoint_list.append(.get_node("passive_spawnpoint2"))
#	passive_spawnpoint_list.append(.get_node("passive_spawnpoint3"))
	timer = get_node("Timer")
	timer.connect("timeout", self, "flood_spawn")
	enemy_spawnpoint_list.append(get_node("spawnpoint"))
	camera = get_node("Camera2D")
#	playername = get_node("CanvasLayer 2")
	HUD = get_node("HUD")
	get_node("HUD/Player1").set_global_pos(Vector2(get_parent().get_rect().size.x - get_parent().get_rect().size.x + 50, get_parent().get_rect().size.y - 75))
	update_hud()
	var e = enemies.instance()
	var p = passive.instance()
	var gi = guns.instance()
	var p1 = Player.instance()
	
	M14 = gi.get_node("Tier_1/M14").duplicate()
	Pistol = gi.get_node("Pistol").duplicate()
	Blaster = gi.get_node("Blaster").duplicate()
	flak_jacket = armour.instance().get_node("Tier_1/body/flakjacket").duplicate()
	combat_helmet = armour.instance().get_node("Tier_1/head/combathelmet").duplicate()
	call_deferred("spawn_gun", get_node("spawnpoint2"))
	call_deferred("spawn_gun", get_node("spawnpoint3"))
	call_deferred("spawn_gun", get_node("spawnpoint"))
	call_deferred("spawn_gun2", get_node("spawnpoint"))
	call_deferred("spawn_armour", get_node("spawnpoint3"))
#	passive_list.append(p.get_node("dead_person").duplicate())
#	passive_list.append(p.get_node("Pig").duplicate())
#	passive_list.append(p.get_node("Giraff").duplicate())
#	passive_list.append(p.get_node("dead_person").duplicate())

#make other functions dependent on player distance and amount of enemies..
	boxdisplay = [get_node("HUD/Player1/boxes/box1"), get_node("HUD/Player1/boxes/box2"), get_node("HUD/Player1/boxes/box3"), get_node("HUD/Player1/boxes/box4"), get_node("HUD/Player1/boxes/box5"), get_node("HUD/Player1/boxes/box6"), get_node("HUD/Player1/boxes/box7"), get_node("HUD/Player1/boxes/box8"), get_node("HUD/Player1/boxes/box9")]
	var player = get_node("Movement/Player")
	call_deferred("passive_spawn", passive_list)
	call_deferred("start_equip", player)
#func spawn_player(spawn):
#	spawn.set_pos(get_node("player_spawn").get_pos())
#	spawn.add_child(Camera2D)
#	self.add_child(spawn)
	set_fixed_process(true)
	
func spawn_armour(spawn):
	var dup = flak_jacket.duplicate()
#	dup.start()
#	dup.generate("Tier_1")
	dup.set_pos(spawn.get_pos())
	add_child(dup)
	dup.unlock()
	var dup1 = combat_helmet.duplicate()
#	dup.start()
#	dup.generate("Tier_1")
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
	
func hit(player, dam):
	for hits in range(dam):
		health_bar_list[player.health - 2].play("health_empty")
		player.health -= 1
		if player.health <= 0:
			get_node("HUD/Player1/health_bar").play("health_empty")
#			print("im dead")

func health_bars(number):
	for bars in health_bar_list:
#		if bars.get_parent() != null:
		call_deferred("queue_free", bars)
#		else:
#			bars.free()
	health_bar_list.clear()
	for bar in range(number - 1):
		var new_health_bar = get_node("HUD/Player1/health_bar").duplicate()
		new_health_bar.set_pos(Vector2(get_node("HUD/Player1/health_bar").get_pos().x + 16 * bar, get_node("HUD/Player1/health_bar").get_pos().y))
#		print (new_health_bar.get_instance_ID())
		health_bar_list.append(new_health_bar)
		call_deferred("deferred", new_health_bar)

func deferred(defer):
	get_node("HUD/Player1").add_child(defer)
	
func clear_ammo():
	for bullet in range(bullet_list.size()):
		bullet_list.back().unlock()
		bullet_list.pop_back()
func ammo(player):
	for bullet in range(player.bullet_list.size()):
		var new_bullet = get_node("HUD/Player1/ammo").duplicate()
		new_bullet.set_pos(Vector2(get_node("HUD/Player1/ammo_position").get_pos().x + 4 * bullet, get_node("HUD/Player1/ammo_position").get_pos().y))
		bullet_list.append(new_bullet)
		call_deferred("deferred", new_bullet)
func update_selected(selected_display):
	selected_display.set_pos(get_node("HUD/Player1/boxes/box9").get_pos())
	get_node("HUD/Player1/boxes").add_child(selected_display)

	
func update_hud():
	total_ammo = get_node("Movement/Player").total_ammo
	current_ammo = get_node("Movement/Player").current_ammo
	total_health = get_node("Movement/Player").total_health
	current_health = get_node("Movement/Player").current_health
	get_node("HUD/Player1/Label 2").set_text(str(current_ammo) + "/" + str(total_ammo))
	var grow = 0
	for items in displaylist:
#		lists.get_parent().remove_child(items)
#		print (lists)
		items.queue_free()
#		displaylist.clear()
#		lists.clear()
#		grow += 1
	displaylist.clear()
	var growing = 0
#	print(get_node("Peter").utility)
	for lists in get_node("Movement/Player").utility:
		if lists != []:
			var udisplay = lists[0].duplicate()
#			print(udisplay.get_name())
			displaylist.append(udisplay)
			udisplay.set_pos(boxdisplay[growing].get_pos())
			get_node("HUD/Player1/boxes").add_child(udisplay)
		growing += 1
		
func shoot(player):
	bullet_list.back().unlock()
	bullet_list.pop_back()
	
func start_equip(player):
	var Uzi = guns.instance().get_node("Tier_1/Uzi").duplicate()
	var Unicorn = guns.instance().get_node("Unicorn").duplicate()
	var dup = Uzi.duplicate()
	dup.generate("Tier_1")
	dup.start()
	player.equip(dup, true, "playerGun")

func flood_spawn():
	e = enemies.instance()
	var enemies = e.get_node("Zombie_soldier").duplicate()
	if flood_spawn > 0:
		enemy_list.append(enemies)
		var listrange = enemy_list.size()
		var dup = M14.duplicate()
#		if enemy_list != []:
		for e in enemy_list:
			enemies.add_collision_exception_with(enemy_list[listrange - 1])
			listrange -= 1
		enemies.set_pos(get_node("spawnpoint2").get_global_pos())
		dup.generate("Tier_1")
		enemies.equip(dup)
		self.add_child(enemies)
		dup.start()
#		enemies.track(get_node("Movement/Player"))
		flood_spawn -= 1
		
func death(dead):
	var listrange = enemy_list.size() - 1
	for e in enemy_list:
#		print(dead.get_instance_ID())
#		print (enemy_list[listrange].get_instance_ID())
		if enemy_list[listrange].get_instance_ID() == dead.get_instance_ID():
			enemy_list.remove(listrange)
		listrange -= 1

func passive_spawn(spawn):
	var spawnpoint_range = passive_spawnpoint_list.size() - 1
#	for spawnpoint in enemy_spawnpoint_list:
	for passive in spawn:
		passive.set_pos(passive_spawnpoint_list[spawnpoint_range].get_global_pos())
#		enemy.get_parent().remove_child(enemy)
		self.add_child(passive)
		passive.add_collision_exception_with(passive_list[0])
		passive.add_collision_exception_with(passive_list[1])
		passive.add_collision_exception_with(passive_list[2])
		passive.add_collision_exception_with(passive_list[3])
#		passive.add_collision_exception_with(passive_list[4])
#		if spawnpoint_range == 0:
#			spawnpoint_range = enemy_spawnpoint_list.size() - 1
		spawnpoint_range -= 1

func _fixed_process(delta):
	get_node("Camera2D").set_pos(get_node("Movement").get_pos())
#	if get_parent().get_rect().size != Vector2(1024, 600):
	get_node("HUD/Player1").set_global_pos(Vector2(get_parent().get_rect().size.x - get_parent().get_rect().size.x + 50, get_parent().get_rect().size.y - 75))