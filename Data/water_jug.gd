extends "res://resource.gd"
var name = "Gasoline"
var weight = 1
var scrap = 0
var food = 0
var medicine = 0
var ammo = 0
var shrapnel = 0
var damage = 2

var amount = 10

var effect = "shock"
var effect_multiplier = 2

func hit(collider):
	var explosion = load("res://Explosives.tscn").instance().get_node("explosion").duplicate()
	explosion.damage = damage
	explosion.shrapnelnumber = shrapnel
#	explosion.faction = faction
	explosion.effect = effect
	explosion.effect_multiplier = effect_multiplier
	explosion.set_collision_mask_bit(1, true)
	explosion.set_collision_mask_bit(2, true)
	explosion.set_pos(get_pos())
	get_parent().add_child(explosion)
	call_deferred("queue_free")

func used():
	amount -= 1
	if amount <= 0:
		queue_free()

func activate():
	var trap = load("res://traps.tscn").instance().get_node("oil_slick").duplicate()
	return trap

func _ready():

	pass
