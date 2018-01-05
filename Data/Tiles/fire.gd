extends Node2D
var damage = 1
var effect = "fire"
var effect_multiplier = 2
var stopping_power = 0
var velocity = Vector2()
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var poison = 0
var critical = false
var drop = false
func _ready():
	get_node("Area2D").set_fixed_process(true)
	# Called every time the node is added to the scene.
	# Initialization here
	pass
