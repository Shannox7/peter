extends KinematicBody2D

var flip_mod = 1
var attack_ready
var WALK_SPEED = 200
var PRONE_SPEED = 100
var ACCELERATION = 5
var DECCELERATION = 10
var acceleration_modifier = 0.5
var AIMSPEED = .05
const WALK_MIN_SPEED = 10
var JUMP_FORCE = 275
var jump_press = 0
var knockback_velocity = Vector2()

var GRAVITY = 600.0
var health
var total_health = 20
var velocity = Vector2()
var flipped = false
var is_prone = false
var target_list = []


var attacking = false
var objective
var attack = false
var follow = false
var hold = false
var retreat = false
var jump_over
var hold_order = 1
var hold_range = 30
var hold_order_remove = false

var left_arm_gone = false
var right_arm_gone = false

var AnimNode
var animNew
var armAnim
var anim

var jump_l
var jump_r
var grounded
var jumping
var arm_r
var arm_l
var head
var legs
var torso
var zombie
var raycast
var deathTime = 2
var primaryGun = []
var secondaryGun = []
var headArmour = []
var bodyArmour = []



var inventory = false

var enemynumber = 2
var sidenumber = 4
var enemyside = "allies"
var side = "enemies"

var holding

#############################################################################
func ready():
	print("enemies")
	pass
#que ordering
func hold_order(state):
	if state == "remove":
		hold_order_remove = true
		var hold_order = 1
		var hold_range = 30
		for enemy in get_parent().enemy_list:
			if enemy.hold_order_remove:
				pass
			else:
				enemy.hold_range = hold_range * hold_order
				hold_order += 1
	elif state == "add":
		hold_order_remove = false
		var hold_order = 1
		var hold_range = 30
		for enemy in get_parent().enemy_list:
			if enemy.hold_order_remove:
				pass
			else:
				enemy.hold_range = hold_range * hold_order
				hold_order += 1
#movement
func Jump():
	if is_prone == true:
		is_prone = false
#		player.prone(false)
#		player.flip(flipped)
	elif grounded:
		jumping = true
		velocity.y = -JUMP_FORCE/2
		jump_press = 0

################################################################################
#fixed processes
#death

#look and move
func go_to(object):
	holding = false
	raycast.set_rot(get_angle_to(object.get_global_pos()) - 3.14159/2)
	if abs(object.get_global_pos().x - get_pos().x) <= hold_range:
		holding = true

func look(object):
	var obj = object.get_global_pos()
	head.set_rot(get_angle_to(obj) - 3.14159/2 * flip_mod)
	raycast.set_rot(get_angle_to(obj) - 3.14159/2)
	head.set_rotd(head.get_rotd() * flip_mod)
	if not right_arm_gone:
		arm_r.set_rotd(head.get_rotd())
	holding = true
	
#movement checks
func gravity_check(delta):
	if grounded:
		pass
	else:
		velocity.y += GRAVITY * delta
		
func grounded_check():
	if (jump_l.is_colliding() or jump_r.is_colliding()):
		grounded = true
		acceleration_modifier = 1
	else:
		grounded = false
		acceleration_modifier = 0.5
		
func flip_check():
	if raycast.get_rotd() < -90  and flipped == false:
		flipped = true
		flip(true)
		jump_over.set_rotd(-90)
	elif raycast.get_rotd() > -90 and flipped == true:
		flipped = false
		flip(false)
		jump_over.set_rotd(90)
		
#targeting and attacking
func attack():
#		if str(target_list.front()) == "[Deleted Object]":
#			target_list.pop_front()
#		elif not get_parent().get_parent().has_node(target_list.front().get_path()):
#			target_list.pop_front()
#		if target_list.front().is_in_group("enemies") != true:
#			print ("why you no in enemies?" )
#			target_list.pop_front()
	if target_list.front().dead:
		untrack(target_list.front())
	else:
		var target = (target_list.front())
		look(target)
		go_to(target)
		if right_arm_gone == false:
			if get_pos().distance_to(target.get_global_pos()) <= (primaryGun[0].bulletspeed * primaryGun[0].distance) * .95:
				holding = true
				primaryGun[0].aiming(true, enemynumber)
				if attack_ready == true and primaryGun[0].current_clip > 0:
					fire()
		elif get_pos().distance_to(target.get_global_pos()) <= 20:
			holding = true
			if attack_ready == true:
				melee()

#movement and animations
func animation():
	if anim != animNew:
		animNew = anim
		AnimNode.play(anim)

func moving(delta):
	if hold or holding:
		if abs(velocity.x) > 0:
			if not grounded:
				velocity.x -= 2 * sign(velocity.x)
				if abs(velocity.x) < 5:
					velocity.x = 0
			else:
				velocity.x -= DECCELERATION * sign(velocity.x)
				if abs(velocity.x) < 5:
					velocity.x = 0
		if not is_prone:
			anim = "idle"
		else:
			anim = "prone_idle"
	elif not grounded:
		if abs(velocity.x) < WALK_SPEED:
			velocity.x += ACCELERATION * flip_mod * acceleration_modifier
			if is_prone:
				anim = "prone_idle"
			else:
				anim = "jump"
	elif not is_prone:
		anim = "run"
		if abs(velocity.x) < WALK_SPEED:
			velocity.x += ACCELERATION * flip_mod
		else:
			velocity.x -= DECCELERATION * sign(velocity.x)
	elif is_prone:
		anim = "prone_crawl"
		if abs(velocity.x) > -PRONE_SPEED:
			velocity.x -= ACCELERATION * flip_mod
		else:
			velocity.x += DECCELERATION / 2 * sign(velocity.x)
	
func jumping(delta):
	if jump_over.is_colliding() and (not hold or not holding):
		if jumping == false:
			Jump()
		elif (jump_press < 0.25) and jumping == true:
			jump_press += delta
			velocity.y -= JUMP_FORCE * 2 * delta
		else:
			jumping = false 

func knockback():
	if abs(knockback_velocity.x) > ACCELERATION or abs(knockback_velocity.y) > ACCELERATION:
		if knockback_velocity.x > 0:
			 knockback_velocity.x -= ACCELERATION
		else:
			knockback_velocity.x += ACCELERATION
		
		if knockback_velocity.y > 0:
			knockback_velocity.y -= ACCELERATION
		else:
			knockback_velocity.y += ACCELERATION
	else:
		knockback_velocity = Vector2()
		
func the_movement(delta):
	var motion = velocity * delta + knockback_velocity
	motion = move(motion)
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)