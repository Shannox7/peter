extends "res://Data/Attacks/Attacks.gd"

var time = 0
func _ready():
	initialize()

func effect(collider, hit):
	hit_effect(collider, hit)
		
#func init():
 # Where angle is the angle you want it to start at
#in fixed_process():
#	velocity += Vector2(0, GRAVITY) * delta # Where gravity is some decently large number ( I use 600)
#	set_rot(velocity.angle() - (3.14 / 2))
#	move(velocity * delta)
	
func _fixed_process(delta):
	distance -= delta
	velocity = Vector2(cos(get_rot()) * delta * bulletspeed * flip_mod, -sin(get_rot()) * delta * bulletspeed * flip_mod)
	if distance <= 0:
		fade()
	move(velocity)
	
	colliding()
	
	
	
	
	
	
#	distance -= delta
#	velocity = Vector2(cos(get_rot()) * delta * bulletspeed * flip_mod, -sin(get_rot()) * delta * bulletspeed * flip_mod)
#	velocity = Vector2(cos(get_rot()) * delta * bulletspeed * flip_mod, -sin(get_rot()) * delta * bulletspeed * flip_mod)
#	velocity.y += 600 * delta
#	velocity.y += 500 * delta
#	set_rot(velocity.angle() - (3.14 / 2))
#	if distance <= 0:
#		drop = true
#		fade()
#	move(velocity)

