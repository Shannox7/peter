extends "res://Guns.gd"

func _ready():
	name = "Rusty AK"
	type = "bullet"
	
	damage = 1
	fire_rate = .3
	accuracy = 10
	distance = .6
	clip_capacity = 10
	reload_speed = 1
#	ammo_capacity = 400