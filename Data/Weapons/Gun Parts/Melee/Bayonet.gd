extends "res://Data/Weapons/Gun Parts/Melee/Melee.gd"
var melee_damage = 3
var melee_stopping_power = 2
var melee_type = "Melee" 

func melee():
	return slash()
	
func _ready():
	pass
