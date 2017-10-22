extends "res://Data/Attacks/Attacks.gd"
#var bulletspeedy
var trajectory
func effect(collider, hit):
	hit_and_explode_effect(collider, hit)
		
func init():
	velocity = Vector2(bulletspeed * flip_mod, 0).rotated(deg2rad(get_rotd())) # Where angle is the angle you want it to start at
	
func _fixed_process(delta):
	velocity += Vector2(0, Gravity) * delta # Where gravity is some decently large number ( I use 600)
	set_rot(velocity.angle() - (3.14 / 2))
	move(velocity * delta)
	colliding()

func _ready():
	initialize()
	init()
