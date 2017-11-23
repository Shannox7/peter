extends "res://Guns.gd"

func _ready():
	name = "Tank Gun"
	type = "vehicle"
	accuracy = 10
	damage = 20
	fire_rate = 3
	distance = 1
	clip_capacity = 1
	reload_speed = 3
	explode_damage = int(rand_range(1, 3))
	shrapnel = 20
func bullettype():
	var new_bullet = b.instance().get_node(str(type) + "/cannon_shell").duplicate()
	new_bullet.faction = get_parent().get_parent().get_parent()
	new_bullet.explode_damage = explode_damage
	new_bullet.shrapnel= shrapnel
	new_bullet.distance = distance
	new_bullet.stopping_power = stopping_power
	new_bullet.damage = damage
	new_bullet.bulletspeed = bulletspeed
	return new_bullet