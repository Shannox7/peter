extends "res://Data/Buildings/Construction.gd"

func show_animations():
	get_node("constructing").show()
	get_node("constructing 2").show()
	get_node("constructing 3").show()
	get_node("constructing 4").show()
func hide_animations():
	get_node("constructing").hide()
	get_node("constructing 2").hide()
	get_node("constructing 3").hide()
	get_node("constructing 4").hide()

func placeable():
	if obstructions == [] and get_node("RayCast2D").is_colliding() and get_node("RayCast2D1").is_colliding() and get_node("RayCast2D2").is_colliding() and get_node("RayCast2D3").is_colliding() and defence_zone != []:
		if get_global_pos().x <= defence_zone[0].get_parent().positions[defence_zone[0].get_parent().positions.size() - (structure.size)].get_global_pos().x and get_global_pos().x >= defence_zone[0].get_parent().positions.front().get_global_pos().x:
			placeable = true
		else:
			placeable = false
	else:
		placeable = false
