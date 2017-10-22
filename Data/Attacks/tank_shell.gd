extends "res://Data/Attacks/Attacks.gd"

func effect(collider, hit):
	hit_and_explode_effect(collider, hit)
		
func _fixed_process(delta):
	distance -= delta
	velocity = Vector2(cos(get_rot()) * delta * bulletspeed * flip_mod, -sin(get_rot()) * delta * bulletspeed * flip_mod)
	if distance <= 0:
		drop = true
		drop(delta)
	move(velocity)
	
	colliding()

func _ready():
	initialize()
