extends "res://Data/Weapons/Gun Parts/Special/Mod.gd"
var name = "Fire"
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

var effect = "fire"
var effect_multiplier = 1

func bullet(bullet):
	var fire = get_node("Particles2D").duplicate()
	bullet.add_child(fire)
	bullet.effect = effect
	bullet.effect_multiplier = effect_multiplier
	bullet.visual_effect = fire
#	fire.set_scale(Vector2(1 * get_parent().get_parent().get_parent().get_parent().get_parent().flip_mod, 1))
	bullet.fire()
	return bullet
	
func _ready():
	stats = [fa]
	# Called every time the node is added to the scene.
	# Initialization here
	pass