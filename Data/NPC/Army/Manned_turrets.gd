extends Node2D

var target_list = []
var low_priority_list = []
var rayNode
var raycast
var timer
#var bullet = preload("res://Bullets.tscn")
var attack = preload("res://Attacks.tscn")

var flipped = false
var flip_mod = 1

var viewarea

var Gun
var attack_ready = true

var reload
var anim

var attack_timer
var wait_time
var reloading
var stats = []
var operator

var host
func _ready():
	host = get_parent().get_parent()
	Gun = get_node("body/Pig")
	raycast = get_node("RayCast2D")
	timer = get_node("Timer")
	viewarea = Gun.get_node("Area2D")
	attack_timer = get_node("Attack")
	attack_timer.set_wait_time(Gun.fire_rate)
	stats = Gun.stats

func track(collider):
	if collider.get_parent().myself in target_list or collider.get_parent().myself in low_priority_list:
		pass
	elif collider.get_parent().has_method("repairing"):
		low_priority_list.append(collider.get_parent().myself)
	else:
		target_list.append(collider.get_parent().myself)
		
func untrack(collider):
	if collider.get_parent().myself in target_list:
		target_list.remove(target_list.find(collider.get_parent().myself))
	elif collider.get_parent().myself in low_priority_list:
		low_priority_list.remove(low_priority_list.find(collider.get_parent().myself))
	
		
func attack_flip():
	attack_ready = true
	attack_timer.set_wait_time(Gun.fire_rate)
	attack_timer.start()
	
func attack():
	var Aimrot = (Gun.get_rot() + host.get_node("body").get_rot()) * host.flip_mod * flip_mod
	var pos = Vector2(cos(Aimrot), -sin(Aimrot)) * host.flip_mod * flip_mod
	var spawn_point = pos + Gun.get_node("body/barrel_tip").get_global_pos()
	for bullets in range(Gun.bullets_inbullets):
		bullets = Gun.bullettype()

		bullets.get_node("Sprite").set_flip_h(flipped)  

		bullets.flip_mod = host.flip_mod * flip_mod
		
		bullets.set_rotd(rad2deg(Aimrot) + rand_range(Gun.accuracy, -Gun.accuracy))
		bullets.set_collision_mask_bit(host.faction.enemynumber, true)
		bullets.set_pos(spawn_point)
		bullets.side = host.faction.side
		host.level.add_child(bullets)

	Gun.shoot()
	attack_ready = false
	if Gun.current_clip <= 0 and Gun.current_ammo > 0:
		reload()
	
func reload():
	attack_timer.set_wait_time(Gun.reload_speed)
	Gun.reload()


func deactivate():
	set_fixed_process(false)
	viewarea.disconnect("body_enter", self, "track")
	viewarea.disconnect("body_exit", self, "untrack")
	attack_timer.disconnect("timeout", self, "attack_flip")

func activate(op):
	operator = op
	set_fixed_process(true)
	viewarea.connect("body_enter", self, "track")
	viewarea.connect("body_exit", self, "untrack")
	attack_timer.connect("timeout", self, "attack_flip")
	viewarea.set_collision_mask_bit(host.faction.enemynumber, true)
	attack_timer.start()

func track_closest(targetlist):
	for targets in targetlist:
		if !targets.get_ref():
			pass
		elif get_global_pos().distance_to(targets.get_ref().get_global_pos()) < get_global_pos().distance_to(targetlist.front().get_ref().get_global_pos()):
			targetlist.remove(targetlist.find(targets.get_ref().myself))
			targetlist.push_front(targets.get_ref().myself)
			break
			
func one_way_target():
	if target_list != []:
		var target = target_list.front().get_ref()
		if !target:
			target_list.pop_front()
		elif target.dead:
			target_list.pop_front()
		else:
			var targeting = (target.get_node("body").get_global_pos())
			if rad2deg(get_node("turret_pos").get_angle_to(targeting) - 3.14159/2) <= 45 and rad2deg(get_node("turret_pos").get_angle_to(targeting) - 3.14159/2) >= -45:
				Gun.set_rot(get_node("turret_pos").get_angle_to(targeting)- 3.14159/2)
				operator.arm_r.set_rotd(Gun.get_rotd() * -1)
				operator.head.set_rot(Gun.get_rot())
				if get_global_pos().distance_to(targeting) <= (Gun.bulletspeed * Gun.distance) * .95 and attack_ready == true and Gun.current_clip > 0: 
					attack()
	else:
		Gun.set_rotd(0)
		operator.arm_r.set_rotd(0)
		operator.head.set_rotd(0)

func flip(flipped):
	if flipped:
		flip_mod = -1
		operator.set_global_pos(host.get_node("body/gunner_pos1").get_global_pos())
	else:
		flip_mod = 1
		operator.set_global_pos(host.get_node("body/gunner_pos").get_global_pos())
	get_node("body").set_scale(Vector2(1  * flip_mod, 1))
	operator.flip(flipped)
	

func flip_check():
	if raycast.get_rotd() < -90  and flipped == false:
		flipped = true
		flip(true)
	elif raycast.get_rotd() > -90 and flipped == true:
		flipped = false
		flip(false)
		
func three_sixty_target():
	if target_list != []:
		var target = target_list.front().get_ref()
		if !target:
			target_list.pop_front()
		elif target.dead:
			target_list.pop_front()
		else:
			var targeting = (target.get_node("body").get_global_pos())
			raycast.set_rot(get_angle_to(targeting)- 3.14159/2)
			Gun.set_rot(get_node("body").get_angle_to(targeting)- 3.14159/2)
			flip_check()
			operator.arm_r.set_rotd(Gun.get_rotd() * -1)

			operator.head.set_rot(Gun.get_rot())
			if get_global_pos().distance_to(targeting) <= (Gun.bulletspeed * Gun.distance) * .95 and attack_ready == true and Gun.current_clip > 0: 
				attack()
#	else:
#		Gun.set_rotd(0)
#		operator.arm_r.set_rotd(0)
#		operator.head.set_rotd(0)