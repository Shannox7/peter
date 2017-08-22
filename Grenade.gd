extends "res://Data/Attacks/Explosives.gd"
var name = "Grenade"
var flip_mod = 1
var gravity = 300
var bulletspeed = 800
var throwx
var throwy
func _ready():
	set_fixed_process(true)
	var damaged = "Dam: " + str(damage)
	var distanced = "Ran: " + str(round(distance/3 * 100))
	var stopping_powerd = "KB: " + str(round(stopping_power/10 * 100))
	stats = [damaged, stopping_powerd, distanced]

func _fixed_process(delta):
#	velocity = Vector2(cos(get_rot()) * delta * bulletspeedx * flip_mod, -sin(get_rot()) * delta * bulletspeedy * flip_mod)
	velocity = Vector2(throwx * delta * flip_mod, throwy * delta)
	throwy += 3
	if throwy >= 100:
		throwy = 100
	velocity.y += gravity * delta
#	gravity += 1
	move(velocity)
	if is_colliding():
		explode()