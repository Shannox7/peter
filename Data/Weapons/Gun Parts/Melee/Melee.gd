extends Node2D

func slash():
	return get_parent().get_parent().Global.attacks.get_node("melee/Gun_melee").duplicate()
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
