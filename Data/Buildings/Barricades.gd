extends "res://Data/Buildings/buildings.gd"
var background = false
var foreground = true

var frontorback = 9


func initialize():
	set_z(10)
	occupency()
	level = get_parent().get_parent()
	faction = get_parent()
	get_node("body").set_layer_mask_bit(frontorback, true)
	myself = weakref(self)
	faction.defence_list.append(myself)
	get_node("body").set_layer_mask_bit(faction.sidenumber, true)
#	set_layer_mask_bit(faction.enemynumber, true)
#	set_collision_mask(faction.enemynumber)
