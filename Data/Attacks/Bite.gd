extends "res://Data/Attacks/Attacks.gd"



func _ready():
	stopping_power = 3
	poison = 3
	initialize()

func effect(collider, hit):
	hit_effect(collider, hit)
	
	
func _fixed_process(delta):
#	distance -= delta
#	velocity = Vector2(cos(get_rot()) * delta * bulletspeed * flip_mod, -sin(get_rot()) * delta * bulletspeed * flip_mod)
	if distance <= 0:
		queue_free()
	distance -= delta
	velocity = Vector2(cos(get_rot()) * delta * bulletspeed * flip_mod, -sin(get_rot()) * delta * bulletspeed * flip_mod)

	move(velocity)
	
	colliding()
		