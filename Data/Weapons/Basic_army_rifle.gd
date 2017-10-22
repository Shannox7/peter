extends "res://Guns.gd"

func _ready():
	name = "AK47"
	damage = 1
	fire_rate = .25
	accuracy = 5
	distance = .5
	
func bullettype():
	var new_bullet = b.instance().get_node("Bullet").duplicate()
#	new_bullet = clip[0].bullet(new_bullet)
	new_bullet.distance = distance
	new_bullet.stopping_power = stopping_power
	new_bullet.damage = damage
	new_bullet.bulletspeed = bulletspeed
	return new_bullet