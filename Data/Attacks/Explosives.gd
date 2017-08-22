extends KinematicBody2D

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
var distance = .2
var stopping_power = 3
var accuracy = 10
var stats = []
var explosive_radius = 360
var enemyside
var side
var enemynumber
var sidenumber
		
func explode():
	blowup = true
	for shrapnel in shrapnel_list:
		shrapnel.set_rotd(rand_range(0, explosive_radius))
		shrapnel.set_global_pos(get_node("Blow_up").get_global_pos())
		get_parent().add_child(shrapnel)
	queue_free()
	
func side(choice):
	if choice == "enemies":
		enemynumber = 2
		sidenumber = 4
		side = "enemies"
		enemyside = "allies"
		
	elif choice == "allies":
		enemynumber = 4
		sidenumber = 2
		side = "allies"
		enemyside = "enemies"
		
func activate(side):
	side(side)
	set_collision_mask(enemynumber)
	var pellets = attack.instance().get_node("Bullet").duplicate()
	shrapnel_list.clear()
	for number in range(shrapnel_number):
		var new_bullet = pellets.duplicate()
		new_bullet.set_collision_mask(enemynumber)
		new_bullet.distance = distance
		new_bullet.stopping_power = stopping_power
		new_bullet.damage = damage
		new_bullet.bulletspeed = 200
		shrapnel_list.append(new_bullet)

