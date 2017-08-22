extends "res://Data/Buildings/Construction.gd"

	
func show_animations():
	get_node("constructing").show()

func hide_animations():
	get_node("constructing").hide()

func placeable():
	if obstructions == [] and get_node("RayCast2D").is_colliding() and defence_zone != []:
		placeable = true
	else:
		placeable = false