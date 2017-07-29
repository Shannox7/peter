extends Sprite
var damage = 2
var stopping_power = 1
var fire_rate = 0.1
var clip_capacity = 10
var current_clip = 10
var ammo_capacity = 400
var current_ammo = 400
var reload_speed = 3
var distance = 1
var accuracy = .2
var fullauto = true
var bullet_list = []
var bullettype
var b = preload("res://PlayerAttacks.tscn")
var stats = []
#var pu = preload("res://Pickup.tscn")
#var barrel_size .. use later maybe
func _ready():
	var damaged = "Dam: " + str(damage)
	var fire_rated = "Rof: " + str(round(fire_rate/3 * 100))
	var accuracyd = "Acc: " + str(round(accuracy/5 * 100))
	var distanced = "Ran: " + str(round(distance/3 * 100))
	var stopping_powerd = "KB: " + str(round(stopping_power/10 * 100))
	var ammo_capacityd = "Ammo: " + str(round(ammo_capacity))
	var clip_capacityd = "Mag: " + str(round(clip_capacity))
	stats = [stopping_powerd, fire_rated, accuracyd, distanced, ammo_capacityd, clip_capacityd]
	
	start()
#	print (bullet_list)
#	print (current_clip)
func start():
#	if get_parent().get_parent().is_in_group("enemies"):
#		bullettype("enemy")
#	else:
	bullettype("player")
	current_clip = int(rand_range(1, clip_capacity))
	ammo()

func bullettype(identity):
	bullettype = b.instance().get_node("Bullet")
	if identity == "enemy":
		bullettype.set_layer_mask_bit(2, false)
		bullettype.set_layer_mask(1)
		bullettype.set_collision_mask_bit(2, false)
		bullettype.set_collision_mask(1)
	else:
		bullettype.set_layer_mask_bit(1, false)
		bullettype.set_layer_mask(2)
		bullettype.set_collision_mask_bit(1, false)
		bullettype.set_collision_mask(2)
func ammo():
	for bullet in range(current_clip):
		var new_bullet = bullettype.duplicate()
		new_bullet.distance = distance
		var accuracy_skew = rand_range(-accuracy, accuracy)
		new_bullet.accuracy = accuracy_skew
		new_bullet.stopping_power = stopping_power
		new_bullet.damage = damage
		bullet_list.append(new_bullet)
#	get_parent().bullet_list = bullet_list
func reload():
	if (current_ammo - current_clip) < clip_capacity:
		current_clip = current_ammo
		current_ammo = 0
	elif current_clip > 0:
		bullet_list.clear()
		current_ammo -= (clip_capacity - current_clip)
		current_clip = clip_capacity
	else:
		current_ammo -= clip_capacity
		current_clip = clip_capacity
	ammo()
func shoot():
	current_clip -= 1
	bullet_list.pop_back()

