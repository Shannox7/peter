extends "res://Guns.gd"

func _ready():
	name = "Sniper"
	damage = 5
	fire_rate = 1.5
	accuracy = 3
	distance = .5
	bulletspeed = 700
func bullettype():
	var new_bullet = b.instance().get_node("Bullet").duplicate()
#	new_bullet = clip[0].bullet(new_bullet)
	new_bullet.distance = distance
	new_bullet.stopping_power = stopping_power
	new_bullet.damage = damage
	new_bullet.bulletspeed = bulletspeed
	return new_bullet