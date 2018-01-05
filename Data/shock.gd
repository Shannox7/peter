extends Node2D
var stopping_power = 0
var velocity = Vector2()
var damage = 1
var effect = "shock"
var effect_multiplier = 1

var time = 1
var total_time = 1

var poison = 0
var critical = false
var drop = false
func _ready():
	get_node("Area2D").set_fixed_process(true)
	# Called every time the node is added to the scene.
	# Initialization here
	pass

