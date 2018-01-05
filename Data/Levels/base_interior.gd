extends "res://Zones.gd"

func _ready():

	Global = get_node("/root/Global")
	enemy_faction = get_node("Enemy_faction")
	faction = get_node("Faction")
#	if Global.player.get_parent() != null:
#		Global.player.get_parent().remove_child(Global.player)
	Global.player.get_node("Camera2D").set_limit(2, 100000)
	Global.player.get_node("Camera2D").set_limit(0, -1000000)
	Global.player.faction = faction
	Global.player.level = self
	Global.player.in_building = true
	faction.add_child(Global.player)
	Global.player.set_global_pos(get_node("player_pos").get_global_pos())
	if loaded == false:
		loaded = true


#		for survivor in Global.party:
#			if survivor == null:
#				pass
#			else:
#				survivor.get_ref().set_global_pos(Vector2(get_node("start_pos").get_global_pos().x + seperate, get_node("start_pos").get_global_pos().y))
#				survivor.get_ref().faction = faction
#				faction.add_child(survivor.get_ref())
#				free_up(survivor)
#				seperate += 10