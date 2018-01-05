extends "res://Guns.gd"

func _ready():
	name = "Sniper"
	type = "bullet"
	damage = 5
	fire_rate = 1.5
	accuracy = 3
	distance = .5
	bulletspeed = 700
func bullettype():
	var new_bullet = Global.attacks.get_node(str(type) + "/direct").duplicate()
#	new_bullet = clip[0].bullet(new_bullet)
	new_bullet.distance = distance
	new_bullet.stopping_power = stopping_power
	new_bullet.damage = damage
	new_bullet.bulletspeed = bulletspeed
	return new_bullet