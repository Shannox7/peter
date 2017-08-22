extends "res://Data/Buildings/buildings.gd"
var background = false
var foreground = true

var frontorback = 9
func activate():
	set_z(-1)
	level = get_parent().get_parent()
	faction = get_parent()
	set_layer_mask_bit(frontorback, true)
	faction.defence_list.append(self)
	set_layer_mask_bit(faction.sidenumber, true)
#	set_layer_mask_bit(faction.enemynumber, true)
	set_collision_mask(faction.enemynumber)
