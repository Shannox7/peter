extends Node2D
var attacks = preload("res://Attacks.tscn").instance()

func slash():
	return attacks.get_node("melee/Gun_melee").duplicate()
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
