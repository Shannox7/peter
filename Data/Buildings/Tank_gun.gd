extends "res://Guns.gd"

func _ready():
	name = "Tank Gun"
	damage = 50
	fire_rate = 3
	distance = 1
	clip_capacity = 1
	reload_speed = 3
	
func bullettype():
	var new_bullet = b.instance().get_node("Tank_bullet").duplicate()

#	new_bullet.fire_rate = fire_rate
#	new_bullet.clip_capacity = clip_capacity
#	new_bullet.reload_speed = reload_speed
	new_bullet.distance = distance
	new_bullet.stopping_power = stopping_power
	new_bullet.damage = damage
	new_bullet.bulletspeed = bulletspeed
	return new_bullet