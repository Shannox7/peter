extends Node2D
var placeable = false
var structure
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_fixed_process(true)
	# Called every time the node is added to the scene.
	# Initialization here
	pass
func check():
	var check = true
	for child in get_node("colliders").get_children():
		if not child.is_colliding():
			check = false
			break
	if check == true:
		if get_node("Area2D").get_overlapping_bodies() != []:
			check = false
#		for child in get_node("non colliders"):
#			if child.is_colliding():
#				check = false
#				break
	return check
func _fixed_process(delta):
#	structure.show()
#	placeable = true
	if check():
		structure.get_node("body/Sprite").set_modulate(Color(1,1,1))
		placeable = true
	else:
		structure.get_node("body/Sprite").set_modulate(Color(1,0,0))
		placeable = false