extends "res://Data/Attacks/Attacks.gd"

func effect(collider, hit):
	explode_effect(collider, hit)

func _ready():
	velocity = Vector2(bulletspeed * flip_mod, 0).rotated(deg2rad(get_rotd()))
	initialize()

func _fixed_process(delta):
	loop(delta)
	
	colliding()