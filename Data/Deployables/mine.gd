extends KinematicBody2D
var named = "mine"
var name = "mine"
var GRAVITY = 300
var velocity = Vector2()
var timer
var enemy
var shrapnel_number = 20
var shrapnel_list = []
var attack = preload("res://Attacks.tscn")
var blowup = false
var placeable = true
var damage = 2
var distance = .3
var stopping_power = 8
var accuracy = 10
var buildable_obstructions = []
var stats = []
func _ready():
	var damaged = "Dam: " + str(damage)
	var distanced = "Ran: " + str(round(distance/3 * 100))
	var stopping_powerd = "KB: " + str(round(stopping_power/10 * 100))
	stats = [damaged, stopping_powerd, distanced]
	var pellets = attack.instance().get_node("Pellets").duplicate()
	shrapnel_list.clear()
#	set_fixed_process(true)
#	timer = get_node("Timer")
	for number in range(shrapnel_number):
		var new_bullet = pellets.duplicate()
		new_bullet.distance = distance
#		var accuracy_skew = rand_range(-accuracy, accuracy)
#		new_bullet.accuracy = accuracy_skew
		new_bullet.stopping_power = stopping_power
		new_bullet.damage = damage
		new_bullet.BULLETSPEED = 500
		shrapnel_list.append(new_bullet)
#		var number = shrapnel_list.size() - 1
		for bullet in shrapnel_list:
			new_bullet.add_collision_exception_with(bullet)
				
func blowing_up(collider):
	if collider.is_in_group("enemies") and blowup == false:
		print("lets blow up")
		blowup = true
#		if flip_mod == -1:
#			bullets.get_node("Sprite").set_flip_h(true)  
#			bullets.flip_mod = -1
#		print (shrapnel_list)
		for shrapnel in shrapnel_list:
			shrapnel.set_rotd(rand_range(180, 0))
#			print (shrapnel)
			shrapnel.set_global_pos(get_global_pos())
			print(shrapnel.get_pos())
			print(get_pos())
#			shrapnel.get_parent().remove_child(shrapnel)
			get_parent().get_parent().add_child(shrapnel)

#		var random = rand_range(0, 3)
#		timer.connect("timeout", self, "blow")
#		timer.set_wait_time(.01)
#		timer.start()
#		call_deferred(self, "queue_free")
#		print (shrapnel_list)
		queue_free()
#func blow():
#	var b = attack.instance().get_node("explosion")
#	var explode = b.duplicate()
#
#	explode.set_pos(get_global_pos())
#	explode.get_parent().remove_child(explode)
#	get_parent().add_child(explode)
#	explode.stopping_power = stopping_power
#	explode.damage = damage
#	explode.distance = distance
#	set_fixed_process(false)
#	queue_free()
	

func set_free():
	free()
func deactivate():
	set_fixed_process(false)
	get_node("CollisionShape2D").set_trigger(true)
	if get_node("Area2D").is_connected("body_enter", self, "non_buildable") == false:
		get_node("Area2D").connect("body_enter", self, "non_buildable")
		get_node("Area2D").connect("body_exit", self, "buildable") 
	set_z(1)
func non_buildable(collider):
	placeable = false
	print(buildable_obstructions)
	buildable_obstructions.append(collider)
func buildable(collider):
	buildable_obstructions.pop_front()
	print(buildable_obstructions)
	if buildable_obstructions == []:
		placeable = true
	
func activate():
	set_z(0)
	set_fixed_process(true)
	get_node("CollisionShape2D").set_trigger(false)
	get_node("Area2D").disconnect("body_enter", self, "non_buildable")
	get_node("Area2D").disconnect("body_exit", self, "buildable") 
	get_node("Area2D").connect("body_enter", self, "blowing_up") 
func hit(collider):
	pass
func _fixed_process(delta):
	if velocity.y >= 0: 
		move(velocity)
	else:
		set_fixed_process(false)