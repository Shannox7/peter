extends Node2D
var GRAVITY = 200
var velocity
var timer
var random
var falling
var size = 4
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
	random = rand_range(-.1, .1)
	falling = get_pos().y
	set_fixed_process(true)
	
func _fixed_process(delta):
	set_pos(Vector2(get_pos().x, falling))
	falling += GRAVITY * delta
	rotate(-.1)
