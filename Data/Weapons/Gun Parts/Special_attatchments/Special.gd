extends Node2D
var attacks = preload("res://Attacks.tscn").instance()

func grenade():
	return attacks.get_node("Grenade").duplicate()
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
