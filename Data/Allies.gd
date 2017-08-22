extends Node2D

var place = false

var side = "allies"
var is_prone = false
var knockback_velocity = Vector2(0, 0)
var knockback

var target_list = []
var objective_list = []
var worldnode
var hit = false
const GRAVITY = 300.0
export var total_health = 10.0
var health
var enemy_stopping_power = 0
var velocity = Vector2()
var rayNode
var raycast
var timer
#var bullet = preload("res://Bullets.tscn")
var enemy
var limbs = preload("res://Limbs.tscn")
var bullet = preload("res://PlayerAttacks.tscn")
var Guns = preload("res://Guns.tscn")

var owner
var ammo
var allyAnimNode
var anim = ""
var animNew = ""
var idle = false
var head
var viewarea
var tracking
var healthBar
var dead = false

var ai
var pos
var attack_ready = true
var flip_mod = 1
var flipped = false
var EquippedGuns = []
var headArmour = []
var bodyArmour = []
var allyGun = []
var secondaryGun = []
var allyArm
var reload
var cast = false
var placeable = false
var sight_pos
var random
#var health_bar_list = []
var healthpos
var patrol = true
var attack_timer
var wait_time
var reloading
var deactivated = false
var buildable_obstructions = []
var basic_gun

var hold = false

func _ready():
#	set_fixed_process(true)
	head = get_node("head")
	raycast = get_node("RayCast2D")
	timer = get_node("Timer")
	viewarea = get_node("head/Area2D")
	viewarea.connect("body_enter", self, "cast")
#	viewarea.connect("body_exit", self, "stop_cast")
	get_node("Area2D").connect("body_exit", self, "untrack")
	allyAnimNode = get_node("body")
	head = get_node("head")
	allyArm = get_node("Arm")
	
#	healthBar = get_node("healthBar")
#	health_bars(total_health)
	
	attack_timer = get_node("Attack")
	attack_timer.set_wait_time(.5)
	attack_timer.connect("timeout", self, "attack_flip")
#	attack_timer.set_active(false)
	tracking = false
	health = total_health
	get_node("hit_timer").connect("timeout", self, "original_colour")
	basic_gun = Guns.instance().get_node("Tier_1/M14").duplicate()
	basic_gun.generate("Tier_1")
	if EquippedGuns == []:
		equip(basic_gun)
		basic_gun.start()
	health()
#	objective_list = get_parent().get_parent().objective_list
func patrol():
	patrol = true
	random = rand_range(1, -1)
	var wait_time = rand_range(1, 5)
	timer.set_wait_time(wait_time)
	timer.start()
	 
func cast(Collider):
#	print("Collider name: " + str(Collider.get_name()))
	if Collider.is_in_group("enemies"):
#		target_list.append(collider)
		track(Collider)
#		var position = Vector2(Collider.get_global_pos().x, Collider.get_global_pos().y - Collider.get_global_pos().y)
#		print (collider.get_name())
#		raycast.set_cast_to(position)
#		print("casting")
#		collider = Collider
#		raycast.add_exception(collider)
#		cast = true
#		print (raycast.get_cast_to())
#		if raycast.is_colliding():
#			print ("colliding")
#			print (raycast.get_collider())
#			if raycast.get_collider().is_in_group("players") or raycast.get_collider().is_in_group("allies"):
#				target_list.append(collider)
#				print(target_list)
				
#		player = collider
		
func track(collider):
#	raycast.add_exception(collider)
#	var number = 0
	if collider in target_list:
		pass
	elif collider == null:
		pass
#	for targets in target_list:
#		if targets != null:
#			if targets.get_instance_ID() == collider.get_instance_ID():
#				target_list.remove(number)
#		else:
#			target_list.remove(number)
#			raycast.remove_exception(collider)
#		number += 1
	elif target_list != []:
		if str(collider) == "[Deleted Object]":
			pass
		elif collider.get_pos() - get_pos() < target_list.front().get_pos() - get_pos():
			target_list.push_front(collider)
		else:
			target_list.append(collider)
	else:
		target_list.append(collider)
#	raycast.set_cast_to(Vector2(0,0))
#		cast = false
#	print ("tracking")
#	print (target_list)
#	tracking = true
#	target = collider
#		playerPos = player.get_pos()
#		print("Spotted!")

func untrack(collider):
	if collider != null:
		if collider.is_in_group("enemies"):
			if collider in target_list:
				target_list.remove(target_list.find(collider))

#func health_bars(number):
#	for bar in range(number - 1):
#		var new_health_bar = healthBar.duplicate()
#		new_health_bar.set_pos(Vector2(healthBar.get_pos().x * -bar, healthBar.get_pos().y))
#		print (new_health_bar.get_instance_ID())
#		health_bar_list.append(new_health_bar)
#		call_deferred("deferred", new_health_bar)
#func deferred(new_health_bar):
#	add_child(new_health_bar)
func attack_flip():
	attack_ready = true
	attack_timer.set_wait_time(allyGun.fire_rate)
	attack_timer.start()
func attack():
	var Aimrot
	Aimrot = allyArm.get_rot() * flip_mod
	var pos = Vector2(cos(Aimrot), -sin(Aimrot)) * allyGun.gun_size * flip_mod
	var spawn_point = pos + get_node("Arm/Gun").get_global_pos()

#	allyGun.bullet_list.back().set_rot(allyArm.get_rot())
#	allyGun.bullet_list.back().set_pos(spawn_point)
#	get_parent().add_child(allyGun.bullet_list.back())
	for bullets in allyGun.bullet_list.back():
		if flip_mod == -1:
			bullets.get_node("Sprite").set_flip_h(true)  
			bullets.flip_mod = -1
		bullets.set_rotd(rad2deg(Aimrot) + rand_range(allyGun.accuracy, -allyGun.accuracy))
		bullets.set_pos(spawn_point)
		bullets.set_collision_mask(4)
		bullets.side = side
		get_parent().get_parent().add_child(bullets)
	allyGun.shoot()
	attack_ready = false
	attack_timer.set_wait_time(allyGun.fire_rate)
	if allyGun.current_clip <= 0 and allyGun.current_ammo > 0:
		reload()
#	else:
#		print('click')

func reload():
#	print("reloading")
	attack_timer.stop()
	attack_timer.set_wait_time(allyGun.reload_speed)
	allyGun.reload()
	attack_timer.start()

func equip(Gun):
#	print (Gun.get_name())
	EquippedGuns.append(Gun)
	get_node("Arm").add_child(Gun)
#	basic_gun.start()
	allyGun = EquippedGuns.front()
	allyGun.set_pos(get_node("Arm/Gun").get_pos())
	allyGun.set_rotd(get_node("Arm/Gun").get_rotd())

func flip(flipped):
	if flipped:
		flip_mod = -1
	else:
		flip_mod = 1
	set_scale(Vector2(1 * flip_mod, 1))
#	head.set_rotd(head.get_rotd() * -1)
#	allyArm.set_rotd(allyArm.get_rotd() * -1)
#	get_node("body").set_flip_h(flipped)
#	head.set_flip_h(flipped)
#	allyArm.set_scale(Vector2(1 * flip_mod, 1))
#	if headArmour != []:
#		headArmour[0].get_node("Sprite").set_flip_h(flipped)
#	if bodyArmour != []:
#		bodyArmour[0].get_node("Sprite").set_flip_h(flipped)
#	if playerGun != []:
#		playerGun[0].flip(flipped)
#	if secondaryGun != []:
#		secondaryGun[0].flip(flipped)
	
	get_node("headcollision").set_pos(head.get_pos())
	if get_parent().is_prone != true:
		head.set_pos(Vector2(0 * flip_mod, -13))
		get_node("body").set_pos(Vector2(0, 5))
#		get_node("Arm/Gun").set_pos(Vector2(13 * flip_mod, -8))
		allyArm.set_pos(Vector2(-5, -3))
		if headArmour != []:
			headArmour[0].set_pos(Vector2(0 , -4))
		if bodyArmour != []:
			bodyArmour[0].set_rotd(0)
			bodyArmour[0].set_pos(Vector2(0, -4))
#		if playerGun != []:
#			playerGun[0].set_pos(get_node("Arm/Gun").get_pos())
		if secondaryGun != []:
			secondaryGun[0].set_pos(Vector2(get_node("AnimatedSprite/secondaryEquip").get_pos().x * flip_mod, get_node("AnimatedSprite/secondaryEquip").get_pos().y))
			secondaryGun[0].set_rotd(-90)

	elif get_parent().is_prone == true:
		get_node("AnimatedSprite").set_pos(Vector2(-4, -2))
		head.set_pos(Vector2(12, -6))
#		get_node("Arm/Gun").set_pos(Vector2(15 * flip_mod, 0))
		allyArm.set_pos(Vector2(-1, -1))
		if headArmour != []:
			headArmour[0].set_pos(Vector2(0, -4))
		if bodyArmour != []:
			bodyArmour[0].set_rotd(-90)
			bodyArmour[0].set_pos(Vector2(2, 0))
		if EquippedGuns != []:
			allyGun.set_pos(get_node("Arm/Gun").get_pos())
		if secondaryGun != []:
			secondaryGun[0].set_rotd(180)
			secondaryGun[0].set_pos(Vector2(get_node("AnimatedSprite/secondaryEquip").get_pos().x + 7, get_node("AnimatedSprite/secondaryEquip").get_pos().y + 3))
#		if aim == true:
#			playerArm.set_pos(Vector2(5 * flip_mod, 10))
	if is_prone:
		get_node("prone").set_trigger(false)
		get_node("standing").set_trigger(true)
		get_node("prone").set_pos(get_node("body").get_pos())
	else:
		get_node("standing").set_trigger(false)
		get_node("prone").set_trigger(true)
		get_node("standing").set_pos(get_node("body").get_pos())
		
func set_free():
	set_fixed_process(false)
	get_parent().queue_free()
func original_colour():
	hit = false
	allyArm.set_modulate(Color(1, 1, 1))
	head.set_modulate(Color(1, 1, 1))
	get_node("body").set_modulate(Color(1, 1, 1))
func hit(collider):
#	if collider.get_global_pos().y < collider.get_global_pos().y:
#		print ("critical")
#		collider.damage = collider.damage * 2
	get_node("hit_timer").start()
	allyArm.set_modulate(Color(255,0, 0))
	head.set_modulate(Color(255,0, 0))
	get_node("body").set_modulate(Color(255,0, 0))
#if attack.get_name() == "Bullet":
#	animation	
#	print(dam)
#	bullethole.duplicate()
#	add_child(bullethole)
#	if flip_effect == true:
#		bullethole.set_flip_h(true)
#		flipbullet = -1
#	bullethole.set_global_pos(Vector2(position.x + 5 * flipbullet, position.y))
#	bullethole.set_z(2)
	if hit == false and not get_parent().in_defence:
		get_parent().knockback_velocity.x = collider.velocity.x * collider.stopping_power
		get_parent().knockback_velocity.y = collider.velocity.y * collider.stopping_power
	hit = true
#	print("knockback_velocity: " + str(knockback_velocity)) 
	health -= collider.damage
	get_node("head/health_meter/health").set_modulate(Color(255, 1, 1))
	if health <= 0 and dead == false:
		death()
	health()
	
func health():
	var scale = 3
	if health > 0.0:
		get_node("head/health_meter/health").set_scale(Vector2(1, (health/total_health) * scale)) 
		if health/total_health > 0.25:
			get_node("head/health_meter/health").set_modulate(Color(0, 255, 0))
		elif health/total_health <= 0.25:
			get_node("head/health_meter/health").set_modulate(Color(255, 0, 0))
	else:
		get_node("head/health_meter/health").set_scale(Vector2(1, 0))
		get_node("head/health_meter/health").set_modulate(Color(255, 0, 0))
		
func death():
#	print ("started at the bottom")
#	print(get_parent().player.ally_list)
	get_parent().get_parent().ally_list.remove(get_parent().get_parent().ally_list.find(get_parent()))
	var hold_order = 1
	var hold_range = 30
	for allys in get_parent().get_parent().ally_list:
		allys.hold_range = hold_range * hold_order
		hold_order += 1
	var deathTime = get_node("death")
	deathTime.set_wait_time(1)
	set_layer_mask_bit(1, false)
	dead = true
	deathTime.start()
	deathTime.connect("timeout", self, "set_free")
	if get_parent().defending:
		get_parent().objective.defenders.remove(get_parent().objective.defenders.find(get_parent()))
		get_parent().objective.occupency()
		get_parent().objective.defend()
#	dropGun()

func dropGun():
	allyGun.get_parent().remove_child(allyGun)
	get_parent().add_child(allyGun)
	allyGun.set_global_pos(get_node("Arm/Gun").get_global_pos())
	allyGun.unlock()