extends KinematicBody2D

var cost = 10
var GRAVITY = 300
var velocity = Vector2()
var timer

var shrapnel_number = 20
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
	var explosive = attack.instance().get_node("explosion").duplicate()
	explosive.set_global_pos(get_node("Blow_up").get_global_pos())
	explosive.set_collision_mask_bit(enemynumber, true)
	get_parent().add_child(explosive)
	for number in range(shrapnel_number):
		var new_bullet = attack.instance().get_node("Bullet").duplicate()
		new_bullet.set_collision_mask_bit(enemynumber, true)
		new_bullet.side = side
		new_bullet.distance = distance
		new_bullet.stopping_power = stopping_power
		new_bullet.damage = damage
		new_bullet.bulletspeed = 200
		new_bullet.set_rotd(rand_range(0, explosive_radius))
		new_bullet.set_global_pos(get_node("Blow_up").get_global_pos())
		get_parent().add_child(new_bullet)
	queue_free()
	
		
func activate(side):
	set_collision_mask_bit(enemynumber, true)

