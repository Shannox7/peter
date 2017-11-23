extends Node2D
var Global
var faction = preload("res://Faction.tscn").instance()
var game_over = false
var buildings = preload("res://buildings.tscn").instance()
var guns = preload("res://Guns.tscn")
var armour = preload("res://armour.tscn")
var enemies = preload("res://Enemies.tscn").instance()

var objective_list = []
var fact1
var fact2

func _ready():
	Global = get_node("/root/Global")
	get_node("Timer").connect("timeout", self, "close")
#	for zones in get_node("dzones").get_children():
#		zones.init()
#		objective_list.append(zones.myself)

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
#	win(fact1, fact2, true)

func level_start():
	fact1.player_list.append(Global.player)
	set_up(Global.player, fact1, false)
#	fact1.call_deferred("add_child", Global.player)
	
	fact2.AI = true
	
#	call_deferred("positioning", fact1, get_node("dzones").get_children().front(), false)
#	call_deferred("positioning", fact2,  get_node("dzones").get_children().back(), true)

func set_up(player, faction, flipped):
#	player.get_parent().remove_child(player)
	player.level = self
	player.faction = faction
	player.set_pos(get_node(str(faction.side) + "_spawn").get_pos())
	player.combat = true
	player.flip(flipped)
	var seperate = 15
	for survivor in Global.party:
		if survivor == null:
			pass
		else:
			if survivor.get_ref().get_parent() != null:
				survivor.get_ref().get_parent().remove_child(survivor.get_ref())
			if survivor.get_ref().AI:
				faction.attacker_list.append(survivor.get_ref().myself)
				survivor.get_ref().objective = Global.player
				survivor.get_ref().orders("follow")
			survivor.get_ref().set_global_pos(Vector2(get_node(str(faction.side) + "_spawn").get_global_pos().x - seperate, get_node(str(faction.side) + "_spawn").get_global_pos().y))
			seperate += 15
			faction.call_deferred("add_child", survivor.get_ref())


func escape():
	pass

func attack():
	for number in range(10):
		var zombie = enemies.get_node("Zombie_movement").duplicate()
		zombie.set_global_pos(get_node("attack").get_global_pos())
		fact2.add_child(zombie)
	for number in range(10):
		var zombie = enemies.get_node("Zombie_movement").duplicate()
		zombie.set_global_pos(get_node("retreat").get_global_pos())
		fact2.add_child(zombie)
	for number in range(10):
		var zombie = enemies.get_node("Zombie_movement").duplicate()
		zombie.set_global_pos(get_node("roof").get_global_pos())
		fact2.add_child(zombie)
	pass
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
	for survivor in fact1.attacker_list:
		if survivor.get_ref().get_parent() != null:
			survivor.get_ref().get_parent().remove_child(survivor.get_ref())
				
	for players in fact2.player_list:
		if not players.AI:
			if players.windows == true:
				players.build_mode_dup.close()
			if players.get_parent() != null:
				players.get_parent().remove_child(players)

	Global.back_to_base()

