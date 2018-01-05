extends Node2D
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
func lazer():
	return get_parent().get_parent().Global.attacks.get_node(str(get_parent().get_parent().type) + "/basic").duplicate()
	
func basic_bullet():
	return get_parent().get_parent().Global.attacks.get_node(str(get_parent().get_parent().type) + "/basic").duplicate()
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
