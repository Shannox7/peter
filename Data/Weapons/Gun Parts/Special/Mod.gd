extends Node2D

# class member variables go here, for example:
# var a = 2
func equip(gun):
	gun.effect = self.effect
	gun.effect_multiplier = self.effect_multiplier
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
