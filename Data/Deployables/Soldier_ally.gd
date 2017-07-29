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
	viewarea.connect("body_exit", self, "stop_cast")
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
	basic_gun = Guns.instance().get_node("Tier_1/M14").duplicate()
	if EquippedGuns == []:
		equip(basic_gun)
#	enemyGun = get_node("arm_r/Gun")
#	ammo = total_ammo
#	patrol()
func patrol():
	patrol = true
	random = rand_range(1, -1)
	var wait_time = rand_range(1, 5)
	timer.set_wait_time(wait_time)
	timer.start()

func cast(collider):
#	print("casting")
	if collider.get_name() == "TileMap" or collider.get_name() == "Obstacles" or collider.get_name() == "slope_left":
		pass
	elif collider.is_in_group("enemies"):
		timer.stop()
		target_list.append(collider)
		print (collider)
		enemy = target_list.front()
		track(enemy)
#	print(target_list)
func stop_cast(collider):
	var nothing
	if collider == enemy:
		print('works')
		enemy = nothing
		target_list.clear()
		tracking = false
		patrol = false
		viewarea.connect("body_enter", self, "cast")
		patrol()

func track(collider):
	tracking = true
#	enemy = target_list.front()
	viewarea.disconnect("body_enter", self, "cast")

func untrack(collider):
	if collider == enemy:
		tracking = false
		print("untrakc")
		
func attack_flip():
	attack_ready = true
	attack_timer.set_wait_time(allyGun.fire_rate)
	attack_timer.start()
func attack():
	print("attacking")
	var Aimrot
	Aimrot = allyArm.get_rot()
	var pos = Vector2(cos(Aimrot), -sin(Aimrot))
	var spawn_point = allyArm.get_pos() + pos + get_global_pos()
	allyGun.bullet_list.back().set_rot(allyArm.get_rot())
	allyGun.bullet_list.back().set_pos(spawn_point)
	get_parent().add_child(allyGun.bullet_list.back())
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
			allyGun.flipped = true
			allyGun.get_node("Sprite").set_flip_h(flipped)
	else:
		flip_mod = 1
#		head.set_rot(-head.get_rot())
		get_node("body").set_flip_h(false)
		head.set_rotd(head.get_rotd() * flip_mod)
		head.set_flip_h(false)
		get_node("Arm").set_flip_h(false)
		if EquippedGuns != []:
			allyGun.flipped = false
			allyGun.get_node("Sprite").set_flip_h(false)

func set_free():
	free()

func hit(collider):
	pass
func jump():
	if abs(velocity.y) < 20:
		velocity.y -= JUMP
func _fixed_process(delta):
	if velocity.y > 0.2 or velocity.y < -0.2:
		acceleration_modifier = 0.5
	else:
		acceleration_modifier = 1
	var force = Vector2(0, GRAVITY)
	if tracking:
		if enemy.dead:
			stop_cast(enemy)
		else:
#			print (rayNode.get_rotd())
			var go_to = (enemy.get_global_pos())
			allyArm.set_rot(get_angle_to(go_to) - 3.14159/2)
			head.set_rot(get_angle_to(go_to) - 3.14159/2 * flip_mod)
			raycast.set_rot(get_angle_to(go_to) - 3.14159/2)

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
					
				
		if is_prone != true:
			head.set_pos(Vector2(3 * flip_mod, -13))
			get_node("body").set_pos(Vector2(3 * flip_mod, 4))
	#		playerArm.set_pos(Vector2(-4 * flip_mod, -5))
	#		playerArm.set_pos(Vector2(0 * flip_mod, 0))
			if EquippedGuns != []:
				allyGun.set_pos(Vector2(10 * flip_mod, 0))
	#			playerGun.set_rotd(0)
			anim = "run"
				
		elif is_prone == true:
			get_node("body").set_pos(Vector2(-4 * flip_mod, -2))
			head.set_pos(Vector2(12 * flip_mod, -6))
	#		playerArm.set_offset(Vector2(7 * flip_mod, 2))
	#		playerArm.set_pos(Vector2(4 * flip_mod, 2))
			allyGun.set_pos(Vector2(15 * flip_mod, 0))
			if EquippedGuns != []:
				allyGun.set_pos(Vector2(0 * flip_mod, 0))
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
