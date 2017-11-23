extends "res://Data/Weapons/Gun Parts/Special/Mod.gd"
var name = "Freeze"
var accuracy = 0
var distance = 0
var stopping_power = 0
var fullauto = true
var fa = "Fully Automatic"
var stats
# extra
var damage = 0
var reload_speed = 0
var fire_rate = 0
var clip_capacity = 0

var effect = "freeze"
var effect_multiplier = 1

func bullet(bullet):
	var frost = get_node("Particles2D").duplicate()
	bullet.add_child(frost)
	bullet.effect = effect
	bullet.effect_multiplier = effect_multiplier
	bullet.visual_effect = frost
	bullet.freeze()
	return bullet
	
func _ready():
	stats = [fa]
	# Called every time the node is added to the scene.
	# Initialization here
	pass
