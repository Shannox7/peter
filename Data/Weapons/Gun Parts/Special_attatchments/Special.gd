extends Node2D
var attacks = preload("res://Attacks.tscn").instance()
var faction

func grenade():
	var attack = attacks.get_node("special/Grenade").duplicate()
	attack.Gravity = 500
	attack.shrapnel = 10
	attack.explode_damage = self.special_damage
	attack.bulletspeed = 300
	attack.faction = faction
	return attack
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
