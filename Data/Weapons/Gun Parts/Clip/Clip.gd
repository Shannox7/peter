extends Node2D
var attacks = preload("res://Attacks.tscn").instance()
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
func lazer():
	return attacks.get_node(str(get_parent().get_parent().type) + "/basic").duplicate()
	
func basic_bullet():
	return attacks.get_node(str(get_parent().get_parent().type) + "/basic").duplicate()
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
