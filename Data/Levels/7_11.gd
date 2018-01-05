extends "res://Zones.gd"
var level
var size = "small"
var type = "grocery"



func _ready():
	level = self
	Global = get_node("/root/Global")
	enemy_faction = get_node("Enemy_faction")
	faction = get_node("Faction")
	Global.player.get_node("Camera2D").set_limit(2, 100000)
	Global.player.get_node("Camera2D").set_limit(0, -1000000)
#	if Global.player.get_parent() != null:
#		Global.player.get_parent().remove_child(Global.player)

	Global.player.faction = faction
	Global.player.level = self
	faction.add_child(Global.player)
	Global.player.set_global_pos(get_node("player_pos").get_global_pos())
	Global.player.in_building = true
	if loaded == false:
		loaded = true
		enemy_reinforce = 3
		get_node("return/opened").set_modulate(door_colour)
		get_node("return/closed").set_modulate(door_colour)
#		for zones in get_node("dzones").get_children():
#			zones.init()
#			objective_list.append(zones.myself)
		loot()
		reinforce()
#		for spawn in get_node("enemy_start").get_children():
#			var zombie = enemies.get_node("Zombie_screamer").duplicate()
#			enemy_faction.add_child(zombie)
#			zombie.set_global_pos(spawn.get_global_pos())

#		for survivor in Global.party:
#			if survivor == null:
#				pass
#			else:
#				survivor.get_ref().set_global_pos(Vector2(get_node("start_pos").get_global_pos().x + seperate, get_node("start_pos").get_global_pos().y))
#				survivor.get_ref().faction = faction
#				faction.add_child(survivor.get_ref())
#				free_up(survivor)
#				seperate += 10