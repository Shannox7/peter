extends "res://Guns.gd"

func _ready():
	name = "Pig"
	type = "bullet"
	damage = 1
	fire_rate = .3
	distance = .8

func bullettype():
	var new_bullet = b.instance().get_node(str(type) + "/basic").duplicate()
#	new_bullet = clip[0].bullet(new_bullet)
	new_bullet.distance = distance
	new_bullet.stopping_power = stopping_power
	new_bullet.damage = damage
	new_bullet.bulletspeed = bulletspeed
	return new_bullet
