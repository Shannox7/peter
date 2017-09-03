extends "res://Data/Weapons/Gun Parts/Special_attatchments/Special.gd"
var special_ammo_cost = .25
var special_damage = 10
var special_stopping_power = 5

func special():
	return grenade()
		
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
