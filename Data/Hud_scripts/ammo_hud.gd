extends Node2D
var GRAVITY = 100
var velocity
var timer
var random
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
func unlock():
	timer = get_node("Timer")
	timer.start()
	timer.connect("timeout", self, "queue_free")
	random = rand_range(-.05, .05)
	set_fixed_process(true)
	
func _fixed_process(delta):
	velocity = Vector2()
	velocity.y += delta * GRAVITY
	rotate(random)
	move(velocity)
