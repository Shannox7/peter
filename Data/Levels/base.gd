extends "res://Zones.gd"

var icon = 10
# roads = 0
# grocery = 1
# department = 2
# weapons = 3
# residential = 4 
# residential small = 5
# small business = 6
# military = 7
# government = 8
# lab = 9
# base = 10
func _ready():
	enemy_reinforce = 0
	faction = get_parent().get_node("Faction")
	enemy_faction = get_parent().get_node("Enemy_faction")
	Global = get_node("/root/Global")
	Global.player.in_building = true
	if loaded == false:
		loaded = true
#		call_deferred("add_foliage")
	pass

