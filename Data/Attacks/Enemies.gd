extends KinematicBody2D

var knockback_velocity
var ACCELERATION

func knockback():
	if abs(knockback_velocity.x) > ACCELERATION or abs(knockback_velocity.y) > ACCELERATION:
		if knockback_velocity.x > 0:
			 knockback_velocity.x -= ACCELERATION
		else:
			knockback_velocity.x += ACCELERATION
		
		if knockback_velocity.y > 0:
			knockback_velocity.y -= ACCELERATION
		else:
			knockback_velocity.y += ACCELERATION
	else:
		knockback_velocity = Vector2()
