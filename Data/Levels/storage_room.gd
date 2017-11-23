extends "res://Zones.gd"

func _ready():
	Global = get_node("/root/Global")
	enemy_faction = get_node("Enemy_faction")
	faction = get_node("Faction")
#	if Global.player.get_parent() != null:
#		Global.player.get_parent().remove_child(Global.player)

	Global.player.faction = faction
	Global.player.level = self
	faction.add_child(Global.player)
	Global.player.set_global_pos(get_node("player_pos").get_global_pos())
	if loaded == false:
		loaded = true
		enemy_reinforce= 3
#		for zones in get_node("dzones").get_children():
#			zones.init()
#			objective_list.append(zones.myself)

		for spawn in get_node("enemy_start").get_children():
			var zombie = enemies.get_node("Zombie_movement").duplicate()
			enemy_faction.add_child(zombie)
			zombie.set_global_pos(spawn.get_global_pos())
		
		for spawn in get_node("Area2D/resource_spawns").get_children():
			var random = round(rand_range(0, 1))
			print(random)
			if random == 1:
				var res = resource.get_node("food").duplicate()
				res.set_global_pos(spawn.get_global_pos())
				add_child(res)
#		for survivor in Global.party:
#			if survivor == null:
#				pass
#			else:
#				survivor.get_ref().set_global_pos(Vector2(get_node("start_pos").get_global_pos().x + seperate, get_node("start_pos").get_global_pos().y))
#				survivor.get_ref().faction = faction
#				faction.add_child(survivor.get_ref())
#				free_up(survivor)
#				seperate += 10