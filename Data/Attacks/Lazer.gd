extends "res://Data/Attacks/Attacks.gd"

func _ready():
	initialize()

func effect(collider, hit):
	if hit:
		collider.hit(self)
		queue_free()
	else:
		queue_free()
	
func _fixed_process(delta):
	distance -= delta
	velocity = Vector2(cos(get_rot()) * delta * bulletspeed * flip_mod, -sin(get_rot()) * delta * bulletspeed * flip_mod)
	if distance <= 0:
		drop = true
		fade()
	move(velocity)
	
	colliding()