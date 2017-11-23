extends "res://Zones.gd"

var icon = 1

func _ready():
	faction = get_parent().get_node("Faction")
	enemy_faction = get_parent().get_node("Enemy_faction")
	Global = get_node("/root/Global")
	if loaded == false:
		loaded = true
		enemy_reinforce = 5
#		for zones in get_node("dzones").get_children():
#			zones.init()
#			objective_list.append(zones.myself)

		for spawn in get_node("enemy_start").get_children():
			var zombie = enemies.get_node("Zombie_screamer").duplicate()
			enemy_faction.call_deferred("add_child", zombie)
			zombie.set_global_pos(spawn.get_global_pos())
	# Called every time the node is added to the scene.
	# Initialization here
	pass


		
		
		