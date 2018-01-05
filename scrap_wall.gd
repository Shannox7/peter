extends "res://resource.gd"
var name = "Scrap"
var weight = 1
var scrap = 0
var food = 0
var medicine = 0
var ammo = 0
var shrapnel = 0
var damage = 0

var amount = 1
var value = 10

#func hit(collider):
#	var explosion = load("res://Explosives.tscn").instance().get_node("explosion").duplicate()
#	explosion.damage = damage
#	explosion.shrapnelnumber = shrapnel
#	explosion.effect = effect
#	explosion.effect_multiplier = effect_multiplier
#	explosion.set_collision_mask_bit(1, true)
#	explosion.set_collision_mask_bit(2, true)
#	explosion.set_pos(get_pos())
#	get_parent().add_child(explosion)
#	call_deferred("queue_free")

func description():
#	var g  = "Extra health: " + str(health) + "/n"
	var desc = "Scrap, throw it on the ground to make a pretty terrible barricade, but it's better than nothing!"
	return desc

func stats():
	return load("res://traps.tscn").instance().get_node("scrap_wall").stats()
	pass

func fundamental():
	return "Wall"

func used():
	amount -= 1
	if amount <= 0:
		queue_free()

func activate():
	var trap = load("res://traps.tscn").instance().get_node("scrap_wall").duplicate()
	return trap

func _ready():

	pass
