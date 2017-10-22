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
var timer = 3

func _ready():
	set_fixed_process(true)
func _fixed_process(delta):
	velocity.x = knockback.x
	velocity.y += delta * GRAVITY
	if abs(knockback.x) < 5:
		pass
	else:
		knockback.x -= 1 * sign(velocity.x)
		add_force(Vector2(), velocity)
	timer -= delta
	if timer <= 0:
		queue_free()
