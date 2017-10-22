extends RigidBody2D
var GRAVITY = 10
var velocity = Vector2()
var flip_mod = 1
var acceleration_modifier = 1
var stopping_power = 0
var flipbullet = 1
var knockback = Vector2()
var random1
var random2
#var random2
var timer
#var random2
func _ready():
#	random1 = int(rand_range(1, 10)) * -10
	knockback.x = stopping_power * flipbullet
	timer= get_node("Timer")
	timer.connect("timeout", self, "queue_free")
#	knockbacky *= stopping_power * random1
#	knockbackx = 100
#	knockbacky = 30
#	add_collision_exception_with(KinematicBody2D)
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
func _fixed_process(delta):
#	get_node("CollisionShape2D").set_pos(Vector2(8 * flip_mod, 0))
#	print (stopping_power)
#	if velocity.y > 0.2 or velocity.y < -0.2:
#		acceleration_modifier = 0.5
#	else:
#		acceleration_modifier = 1
	velocity.x = knockback.x
	velocity.y += delta * GRAVITY
	if abs(knockback.x) < 1:
		pass
	else:
#		velocity.x += delt
		knockback.x -= 1 * flipbullet
		apply_impulse(Vector2(), velocity)
	print (str(velocity))
	
