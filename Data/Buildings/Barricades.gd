extends "res://Data/Buildings/buildings.gd"
var background = false
var foreground = true
var damage = 0
var frontorback = 9

var skill = ""
func initialize():
	set_z(10)
	occupency()
#	for def in get_node("body/defence_pos").get_children():
#		defence_pos.append(def)
	level = get_parent().get_parent()
	faction = get_parent()
	get_node("body").set_layer_mask_bit(frontorback, true)
	myself = weakref(self)
	faction.defence_list.append(myself)
	get_node("body").set_layer_mask_bit(faction.sidenumber, true)
#	set_layer_mask_bit(faction.enemynumber, true)
#	set_collision_mask(faction.enemynumber)
