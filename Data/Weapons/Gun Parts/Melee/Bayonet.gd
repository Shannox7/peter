extends "res://Data/Weapons/Gun Parts/Melee/Melee.gd"
var melee_damage = 1
var melee_stopping_power = 2
var melee_type = "Melee" 

var effect = "fire"
var effect_multiplier = 0
func melee():
	return slash()
	
func _ready():
	pass
