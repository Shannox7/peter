extends KinematicBody2D
const FLOOR_ANGLE_TOLERANCE = 46
export var WALK_SPEED = 150
export var PRONE_SPEED = 60
export var CROUCH_SPEED = 100
export var ACCELERATION = 20
export var DECCELERATION = 10
export var acceleration_modifier = 1
export var AIMSPEED = .05
var JUMP = 250
var place = false
#slopes V
const SLIDE_STOP_VELOCITY = 1.0 # One pixel per second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # One pixel
var on_air_time = 100
const STOP_FORCE = 1300
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 150

var is_prone = false
var knockback_velocity = Vector2(0, 0)
var knockback
var attack_speed = 200
var target_list = []
var worldnode
var hit = false
const GRAVITY = 300.0
export var total_health = 10
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
var flipbullet = 1
var flip_mod = 1
var flipped = false
var EquippedGuns = []
var allyGun
var allyArm
var reload
var cast = false
var placeable = false
var sight_pos
var random
var health_bar_list = []
var healthpos
var patrol = true
var attack_timer
var wait_time
var reloading
var deactivated = false
var buildable_obstructions = []
var basic_gun

#commands
var hold = false
func _ready():
	set_fixed_process(true)
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
	
	healthBar = get_node("healthBar")
	health_bars(total_health)
	
	attack_timer = get_node("Attack")
	attack_timer.set_wait_time(.5)
	attack_timer.connect("timeout", self, "attack_flip")
#	attack_timer.set_active(false)
	tracking = false
	health = total_health
	basic_gun = Guns.instance().get_node("Tier_1/M14").duplicate()
	basic_gun.generate("Tier_1")
	if EquippedGuns == []:
		equip(basic_gun)
		basic_gun.start()
#	enemyGun = get_node("arm_r/Gun")
#	ammo = total_ammo
#	patrol()
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
		var position = Vector2(Collider.get_global_pos().x, Collider.get_global_pos().y - Collider.get_global_pos().y)
#		print (collider.get_name())
		raycast.set_cast_to(position)
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
	var number = 0
	for targets in target_list:
		if targets.get_instance_ID() == collider.get_instance_ID():
			target_list.remove(number)
#			raycast.remove_exception(collider)
		number += 1
	if target_list != []:
		if collider.get_pos() - get_pos() < target_list.front().get_pos() - get_pos():
			target_list.push_front(collider)
		else:
			target_list.append(collider)
	else:
		target_list.append(collider)
#	raycast.set_cast_to(Vector2(0,0))
	cast = false
	print ("tracking")
	print (target_list)
#	tracking = true
#	target = collider
#		playerPos = player.get_pos()
#		print("Spotted!")

func untrack(collider):
	if collider != null:
		if collider.is_in_group("enemies"):
			var number = 0
			for targets in target_list:
				if targets.get_instance_ID() == collider.get_instance_ID():
					target_list.remove(number)
	#				raycast.remove_exception(collider)
				number += 1
		#	tracking = false
#		print("untrakc")
#		print (target_list)
		
func health_bars(number):
	for bar in range(number - 1):
		var new_health_bar = healthBar.duplicate()
		new_health_bar.set_pos(Vector2(healthBar.get_pos().x * -bar, healthBar.get_pos().y))
#		print (new_health_bar.get_instance_ID())
		health_bar_list.append(new_health_bar)
		call_deferred("deferred", new_health_bar)
func deferred(new_health_bar):
	add_child(new_health_bar)
func attack_flip():
	attack_ready = true
	attack_timer.set_wait_time(allyGun.fire_rate)
	attack_timer.start()
func attack():
	print("attacking")
	var Aimrot
	Aimrot = allyArm.get_rot()
	var pos = Vector2(cos(Aimrot), -sin(Aimrot))
	var spawn_point = pos + get_global_pos()
#	allyArm.get_pos() +
#	allyGun.bullet_list.back().set_rot(allyArm.get_rot())
#	allyGun.bullet_list.back().set_pos(spawn_point)
#	get_parent().add_child(allyGun.bullet_list.back())
	for bullets in allyGun.bullet_list.back():
		if flip_mod == -1:
			bullets.get_node("Sprite").set_flip_h(true)  
			bullets.flip_mod = -1
		bullets.set_rotd(rad2deg(Aimrot) + rand_range(allyGun.accuracy, -allyGun.accuracy))
		bullets.set_pos(spawn_point)
		get_parent().add_child(bullets)
	allyGun.shoot()
	attack_ready = false
	attack_timer.set_wait_time(allyGun.fire_rate)
	if allyGun.current_clip <= 0 and allyGun.current_ammo > 0:
		reload()
	else:
		print('click')

func reload():
	print("reloading")
	attack_timer.stop()
	attack_timer.set_wait_time(allyGun.reload_speed)
	allyGun.reload()
	attack_timer.start()

func equip(Gun):
	print (Gun.get_name())
	EquippedGuns.append(Gun)
	get_node("Arm").add_child(Gun)
	basic_gun.start()
	allyGun = EquippedGuns.front()
	allyGun.set_pos(get_node("Arm/Gun").get_pos())
	allyGun.set_rotd(get_node("Arm/Gun").get_rotd())

func flip():
	if flipped == true:
		flip_mod = -1
		get_node("body").set_flip_h(flipped)
		head.set_rotd(head.get_rotd() * flip_mod)
		head.set_flip_h(flipped)
		get_node("Arm").set_flip_h(flipped)
		if EquippedGuns != []:
			allyGun.flip(true)
	else:
		flip_mod = 1
#		head.set_rot(-head.get_rot())
		get_node("body").set_flip_h(false)
		head.set_rotd(head.get_rotd() * flip_mod)
		head.set_flip_h(false)
		get_node("Arm").set_flip_h(false)
		if EquippedGuns != []:
			allyGun.flip(false)
#			allyGun.get_node("Sprite").set_flip_h(false)
	if is_prone != true:
		head.set_pos(Vector2(3 * flip_mod, -13))
		get_node("body").set_pos(Vector2(3 * flip_mod, 4))
		allyArm.set_pos(Vector2(-4 * flip_mod, -5))
		if EquippedGuns != []:
			allyGun.set_pos(Vector2(10 * flip_mod, 0))
#			playerGun.set_rotd(0)
		anim = "run"
			
	elif is_prone == true:
		get_node("body").set_pos(Vector2(-4 * flip_mod, -2))
		head.set_pos(Vector2(12 * flip_mod, -6))
#			allyArm.set_pos(Vector2(4 * flip_mod, 2))
		allyGun.set_pos(Vector2(15 * flip_mod, 0))
		if EquippedGuns != []:
			allyGun.set_pos(Vector2(0 * flip_mod, 0))
func set_free():
	set_fixed_process(false)
	queue_free()

func hit(collider):
	if collider.get_global_pos().y < collider.get_global_pos().y:
#		print ("critical")
		collider.damage = collider.damage * 2

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
	knockback_velocity.x = collider.velocity.x * collider.stopping_power
	knockback_velocity.y = collider.velocity.y * collider.stopping_power
#	print("knockback_velocity: " + str(knockback_velocity)) 
	if dead == false:
		for hits in range(collider.damage):
#			print(health)
			health_bar_list[health - 2].play("health_empty")
			health -= 1
			print ("soldier shot!")
		if health <= 0 and dead == false:
			healthBar.play("health_empty")
#			dismember(head)
#			dismember(torso)
			death()
#			print ("shot meh")

func death():
#	print ("started at the bottom")
	var deathTime = get_node("death")
	deathTime.set_wait_time(1)
	set_layer_mask_bit(0, false)
	set_collision_mask_bit(0, false)
	set_layer_mask(5)
	set_collision_mask(5)

#	get_node("CollisionShape2D").set_trigger(true)
	dead = true
#	get_parent().death(self)
#			print ("taking out the traaaaaaaash")
	deathTime.start()
	deathTime.connect("timeout", self, "set_free")
	dropGun()

func dropGun():
	allyGun.get_parent().remove_child(allyGun)
	get_parent().add_child(allyGun)
	allyGun.set_global_pos(get_node("Arm/Gun").get_global_pos())
	allyGun.unlock()

func jump():
	if abs(velocity.y) < 20:
		velocity.y -= JUMP
func _fixed_process(delta):
	if velocity.y > 0.2 or velocity.y < -0.2:
		acceleration_modifier = 0.5
	else:
		acceleration_modifier = 1
	var force = Vector2(0, GRAVITY)
	if dead == true:
#		print (get_rotd())
		if get_rotd() > -90 and get_rotd() < 90: 
#			print("rotation")
			rotate(.05 * flip_mod)
			anim = "idle"
#			velocity.x = kn
			move(velocity)
		else:
			pass
	elif target_list != []:
		if target_list.front().dead:
			untrack(enemy)
#			stop_cast(enemy)
		else:
#			print (rayNode.get_rotd())
			var go_to = (target_list.front().get_global_pos())

			head.set_rot(get_angle_to(go_to) - 3.14159/2 * flip_mod)
			raycast.set_rot(get_angle_to(go_to) - 3.14159/2)
			allyArm.set_rot(head.get_rot())
			if raycast.get_rotd() < -90  and flipped == false:
				flipped = true
				flip()
			elif raycast.get_rotd() > -90 and flipped == true:
				flipped = false
				flip()
			timer.set_active(false)
			velocity.x = max(min(velocity.x + ACCELERATION * acceleration_modifier * flip_mod, WALK_SPEED), -WALK_SPEED)
			if abs(go_to.x - get_pos().x) <= 50 + allyGun.distance * 100: 
				velocity.x = 0
				if attack_ready == true and allyGun.current_clip > 0:
					attack()
			elif abs(go_to.x - get_pos().x) <= 20 and abs(go_to.y - get_pos().y) <= 25:
				velocity.x = 0
				if attack_ready == true:
					attack()
			elif go_to.y - get_pos().y <= -40 and abs(velocity.y) < 20:
				jump() 
			anim = "run"

	else:
		if hold == true:
			velocity.x = 0 
		else:
			var player_pos = owner.get_global_pos()
			velocity.x = max(min(velocity.x + ACCELERATION * acceleration_modifier * flip_mod, WALK_SPEED), -WALK_SPEED)
			raycast.set_rot(get_angle_to(player_pos) - 3.14159/2)
			head.set_rot(get_angle_to(player_pos) - 3.14159/2 * flip_mod)
			if abs(player_pos.x - get_pos().x) <= 50: 
				velocity.x = 0
					
				

	get_node("headcollision").set_pos(head.get_pos())
	
#	var stop = true
#	if is_prone != true:
#		anim = "run_r"
#	elif is_prone == true:
#		anim = "prone_crawl_r"
#	if velocity.x > 0:
#		velocity.x = max(velocity.x - ACCELERATION * acceleration_modifier, 0)
#	else:
#		velocity.x = min(velocity.x + ACCELERATION * acceleration_modifier, 0)
#	if is_prone != true:
#		anim = "idle_r"
#	elif is_prone == true:
#		anim = "prone_idle_r"
	if abs(velocity.x) < 30:
		anim = "idle_r"
	else:
		anim = "run"
	velocity += force*delta
	var motion = velocity*delta
	motion = move(motion)
	var floor_velocity = Vector2()
	
	if (is_colliding()):
		var n = get_collision_normal()
		if get_collider().get_name() == "Obstacles":
			if velocity.x != 0:
				jump()
		if (rad2deg(acos(n.dot(Vector2(0, -1)))) < FLOOR_ANGLE_TOLERANCE):
			on_air_time = 0
			floor_velocity = get_collider_velocity()
#			if (stop):
#				var vsign = sign(velocity.x)
#				var vlen = abs(velocity.x)
#		
#				vlen -= STOP_FORCE*delta
#				if (vlen < 0):
#					vlen = 0
#				velocity.x = vlen*vsign
			acceleration_modifier = 1
			
			if abs((rad2deg(acos(n.dot(Vector2(0, -1))))) - get_rotd()) < .1 or (rad2deg(acos(n.dot(Vector2(0, -1))))) == 0:
				set_rotd((rad2deg(acos(n.dot(Vector2(0, -1))))))
#				print("woop")
			elif get_collider().get_name() == "slope_left" and (rad2deg(acos(n.dot(Vector2(0, -1)))) * - 1) < get_rotd():
				rotate(-.1)
			elif get_collider().get_name() != "slope_left" and (rad2deg(acos(n.dot(Vector2(0, -1))))) > get_rotd() and (rad2deg(acos(n.dot(Vector2(0, -1))))) >= 0:
				rotate(.1)
			elif (rad2deg(acos(n.dot(Vector2(0, -1))))) == 0 and get_rotd() > 0:
				rotate(-.1)

		if (on_air_time == 0 and velocity.x == 0 and get_travel().length() < SLIDE_STOP_MIN_TRAVEL and abs(velocity.x) < SLIDE_STOP_VELOCITY and get_collider_velocity() == Vector2()):
			revert_motion()
			velocity.y = 0.0
		else:
			motion = n.slide(motion)
			velocity = n.slide(velocity)
			move(motion)
	else:
		if get_rotd() > 0 and velocity.y > 5:
			rotate(-.05)
#			print("mmkay")
		elif get_rotd() < 0 and velocity.y > 5:
			rotate(.05)
#			print("yakay")
	if (floor_velocity != Vector2()):
		move(floor_velocity*delta) 
	on_air_time += delta
	
	if anim != animNew:
		animNew = anim
		allyAnimNode.play(anim)
		
#	if armanim != armanimnew:
#		armanimnew = armanim
#		playerArmAnimNode.play(armanim)
	if is_prone:
		get_node("prone").set_trigger(false)
		get_node("standing").set_trigger(true)
		get_node("prone").set_pos(get_node("body").get_pos())
	else:
		get_node("standing").set_trigger(false)
		get_node("prone").set_trigger(true)
		get_node("standing").set_pos(get_node("body").get_pos())
	if raycast.get_rotd() < -90  and flipped == false:
		flipped = true
		flip()
	elif raycast.get_rotd() > -90 and flipped == true:
		flipped = false
		flip()
