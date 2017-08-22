extends Node2D
var name = "M14"
var named = "M14"
var gun_size = 20
var value = 10
var damage = 1
var bulletspeed = 500
var stopping_power = 1
var fire_rate = 0.1
var clip_capacity = 120
var current_clip = 120
var ammo_capacity = 400
var current_ammo = 400
var is_equipped = false
var stats
var reload_speed = 3
var distance = .5
var accuracy = 2
var fullauto = false
var bullets_inbullets = 1
var bullet_list = []
var bullettype
var b = preload("res://Attacks.tscn")
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

#	stats = [stopping_powerd, fire_rated, accuracyd, distanced, ammo_capacityd, clip_capacityd]
func start():
	bullettype("player")
	current_clip = int(rand_range(1, clip_capacity))
	ammo()
func bullettype(identity):
	bullettype = b.instance().get_node("Bullet")

func ammo():
	for bullet in range(current_clip):
		bullet_list.append([])
	for lists in bullet_list:
		for number in range(bullets_inbullets):
			var new_bullet = bullettype.duplicate()
			new_bullet.distance = distance
#			var accuracy_skew = rand_range(-accuracy, accuracy)
#			new_bullet.accuracy = accuracy_skew
			new_bullet.stopping_power = stopping_power
			new_bullet.damage = damage
			new_bullet.bulletspeed = bulletspeed
			lists.append(new_bullet)
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
