extends "res://Zones.gd"

var icon = 1
# roads = 0
# 
#
#
func _ready():
	faction = get_parent().get_node("Faction")
	enemy_faction = get_parent().get_node("Enemy_faction")
	Global = get_node("/root/Global")
	if loaded == false:
		loaded = true
	pass

