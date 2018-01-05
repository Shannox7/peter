extends RigidBody2D
var GRAVITY = 10
var velocity = Vector2(1, 0)
var flip_mod = 1
var acceleration_modifier = 1
var stopping_power = 0
var flipbullet = 1
var knockback = Vector2()
var random1
var random2
var timer = 10
func decap(c):
	var angle
	if c != null:
		velocity = c
#		flip_mod = c.flip_mod
		angle = velocity.angle() - (3.14 / 2)
		set_angular_velocity(angle)
#	if collider == RayCast:
#		apply_impulse(Vector2(), velocity * 25)
#	elif collider == KinematicBody2D:
	apply_impulse(Vector2(), velocity * 25)

#	set_angular_velocity( 10 * sign(velocity.x))
	set_fixed_process(true)
	
func _ready():
#	set_fixed_process(true)
	pass
	
func _fixed_process(delta):
#	velocity.x = knockback.x
#	velocity.y += delta * GRAVITY
#	if abs(knockback.x) < 5:
#		pass
#	else:
#		knockback.x -= 1 * sign(velocity.x)
#	collider.get_collison_pos()

	timer -= delta
	if timer <= 0:
		call_deferred("queue_free")
