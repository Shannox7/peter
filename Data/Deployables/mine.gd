extends Area2D
var named = "mine"
var name = "mine"
var cost = 10
var GRAVITY = 300
var velocity = Vector2()
var timer

var shrapnel_number = 100
var shrapnel_list = []
var attack = preload("res://Attacks.tscn")
var blowup = false
var placeable = true
var damage = 2
var distance = .3
var stopping_power = 8
var accuracy = 10
var stats = []

var enemy
var side
var enemynumber
var sidenumber
func _ready():
	var damaged = "Dam: " + str(damage)
	var distanced = "Ran: " + str(round(distance/3 * 100))
	var stopping_powerd = "KB: " + str(round(stopping_power/10 * 100))
	stats = [damaged, stopping_powerd, distanced]
	connect("body_enter", self, "explode")
func red():
	get_node("body").set_modulate(Color(255, 0, 0))
func original_colour():
	get_node("body").set_modulate(Color(1, 1, 1))
	
#func blowing_up(collider):
#	if collider.is_in_group("enemies") and blowup == false:
#		print("lets blow up")
#		blowup = true
#		for shrapnel in shrapnel_list:
#			shrapnel.set_rotd(rand_range(180, 0))
#			shrapnel.set_global_pos(get_global_pos())
#			get_parent().get_parent().add_child(shrapnel)

#		var random = rand_range(0, 3)
#		timer.connect("timeout", self, "blow")
#		timer.set_wait_time(.01)
#		timer.start()
#		call_deferred(self, "queue_free")
#		print (shrapnel_list)
#		queue_free()
		
func explode(collider):
#	var explode = attack.instance().get_node("explosion").duplicate()
	if collider.is_in_group("enemies"):
		print("lets blow up")
		blowup = true
		for shrapnel in shrapnel_list:
			shrapnel.set_rotd(rand_range(0, 180))
			shrapnel.set_global_pos(get_node("Blow_up").get_global_pos())
			get_parent().add_child(shrapnel)
		queue_free()
	

func set_free():
	free()

func activate(s, n, e, en):
	set_z(0)
	enemy = e
	side = s
	enemynumber = en
	sidenumber = n
	add_to_group(s)
#	set_layer_mask(n)
	set_collision_mask(sidenumber)
	connect("body_enter", self, "explode")
#	set_layer_mask_bit(9, true)
	var pellets = attack.instance().get_node("Bullet").duplicate()
	shrapnel_list.clear()
	for number in range(shrapnel_number):
		var new_bullet = pellets.duplicate()
		new_bullet.set_collision_mask(enemynumber)
		new_bullet.distance = distance
		new_bullet.stopping_power = stopping_power
		new_bullet.damage = damage
		new_bullet.bulletspeed = 500
		shrapnel_list.append(new_bullet)
	
