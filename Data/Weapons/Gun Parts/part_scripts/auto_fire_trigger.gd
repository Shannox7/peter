extends "res://Data/Weapons/Gun Parts/Special/Mod.gd"
var name = "Automatic Chamber"
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

func bullet(bullet):
	bullet = get_parent().b.instance().get_node("Lazer")
	return bullet
	
func _ready():
	stats = [fa]
	# Called every time the node is added to the scene.
	# Initialization here
	pass
