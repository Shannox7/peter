extends Node2D
var GRAVITY = 100
var velocity
var random

var pickup_area
var pickup = false
var player
func _ready():
	get_node("Pickup/pick me up!").hide()
	set_fixed_process(true)
	set_process_input(true)
	random = rand_range(-.05, .05)
	pickup = false
	pickup_area = get_node("Pickup")
	pickup_area.connect("body_enter", self, "pickmeup")
	pickup_area.connect("body_exit", self, "cantpickmeup")
	
func lock():
	set_fixed_process(false)
	set_process_input(false)
	get_node("CollisionShape2D").set_trigger(true)
	get_node("Pickup").hide()
	pickup_area.disconnect("body_enter", self, "pickmeup")
	pickup_area.disconnect("body_exit", self, "cantpickmeup")
	pickup = false
#	print('we locked')
	
func pickmeup(collider):
	if collider.get_name() == "Peter":
		pickup = true
		get_node("Pickup/pick me up!").show()
		player = collider
		
func cantpickmeup(collider):
	if collider.get_name() != "TileMap" or collider.get_name() != "TileMap 2":
		pickup = false
		get_node("Pickup/pick me up!").hide()

func _fixed_process(delta):
	velocity = Vector2()
	velocity.y += delta * GRAVITY
	get_node("CollisionShape2D").set_trigger(false)
		
	if is_colliding():
		pass
	else:
		rotate(random)
	move(velocity)

func _input(event):
	if event.is_action_pressed("pickup") and pickup == true:
		pass
