extends "res://Zones.gd"

var road_sign = ''
var road = null
var icon = 0

var level
func _ready():
	level = get_parent()
	faction = get_parent().get_node("Faction")
	enemy_faction = get_parent().get_node("Enemy_faction")
	Global = get_node("/root/Global")
	if loaded == false:
		is_road = true
		loaded = true
		get_node("street_sign/Label").set_text(road_sign)
#		call_deferred("add_foliage")
		enemy_reinforce = 0
#		for zones in get_node("dzones").get_children():
#			zones.init()
#			objective_list.append(zones.myself)
#
#		for spawn in get_node("enemy_start").get_children():
#			var zombie = enemies.get_node("Zombie_screamer").duplicate()
#			enemy_faction.call_deferred("add_child", zombie)
#			zombie.set_global_pos(spawn.get_global_pos())
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	


func chased():
	chased = true
#	if current_door != null:
#		current_door.chased()
#	else:
	get_node("travel").chased()
#	current_door = null