extends KinematicBody2D

#values
var WALK_SPEED = 200
var PRONE_SPEED = 100
var ACCELERATION = 5
var DECCELERATION = 10
var acceleration_modifier = 0.5
var GRAVITY = 600.0
var JUMP_FORCE = 275
var jump_press = 0
var deathTime = 2
var flip_mod = 1
var hold_order = 1
var hold_range = 30
var health = 10.0
var total_health = 10.0
var armour = 0
var melee_stopping_power = 3
var remove_comment_time = 0
var velocity = Vector2()
var knockback_velocity = Vector2()

#orders
var objective
var attacking = false
var attack = false
var follow = false
var hold = false
var retreat = false
var hold_order_remove = false

#bools
var reloading = false
var hit = false
var cast = false
var tracking = false
var flipped = false
var is_prone = false
var left_arm_gone = false
var right_arm_gone = false
var dead = false
var melee = false
var attack_ready = true
var patrol
var grounded
var jumping

#anims
var animNode
var animNew
var anim

var armanim
var armanimNew 
var armanimNode

#parent var
var level 
var faction

#variable nodes
var spawn_home
var comment
var comment_box 
var jump_l
var jump_r
var jump_over
var arm_r
var arm_l
var head
var legs
var torso
var zombie
var raycast
var viewarea
var fire_ready
var health_display

#lists
var pack = []
var primaryGun = []
var secondaryGun = []
var headArmour = []
var bodyArmour = []
var target_list = []

#side
var side
var holding

#############################################################################
#comments
func comment(say):
	comment_box.show()
	comment.set_text(str(say))
	if remove_comment_time <= 0:
		remove_comment_time = 2 

func remove_comment(delta):
	if remove_comment_time > 0:
		remove_comment_time -= delta
	else:
		comment_box.hide()
		comment.set_text("") 
#flip
func flip(flipped):
	if flipped:
		flip_mod = -1
	else:
		flip_mod = 1
	get_node("body").set_scale(Vector2(1 * flip_mod, 1))
	
#side
func side():

	get_node("body").set_layer_mask_bit(faction.sidenumber, true)
	get_node("body").add_to_group(faction.side)
	get_node("body/head/Area2D").set_collision_mask_bit(faction.enemynumber, true)
	get_node("body/Area2D").set_collision_mask_bit(faction.enemynumber, true)
	
#func side(choice):
#	if choice == "enemies":
#		enemynumber = 2
#		sidenumber = 4
#		enemyside = "allies"
#		side = "enemies"
#		if is_in_group("engineers"):
#			sidelist = get_parent().enemy_engineer_list
#		elif is_in_group("engineers"):
#			sidelist = get_parent().enemy_list
#		sidelist.append(self)
#		sidebuildlist = get_parent().enemy_build_list
#		sidedefencelist = get_parent().enemy_defence_list
#		get_node("body").add_to_group("enemies")
#		get_node("body").set_collision_mask(sidenumber)
#
#
#	elif choice == "allies":
#		enemynumber = 4
#		sidenumber = 2
#		enemyside = "enemies"
#		side = "allies"
#		if self.is_in_group("engineers"):
#			sidelist = get_parent().ally_engineer_list
#		else:
#			sidelist = get_parent().ally_list
#		sidelist.append(self)
#		sidebuildlist = get_parent().ally_build_list
#		sidedefencelist = get_parent().ally_defence_list
#		get_node("body").add_to_group("allies")
#		get_node("body").set_collision_mask(sidenumber)

#que ordering
func hold_order(state):
	if state == "remove":
		hold_order_remove = true
		var hold_order = 1
		var hold_range = 30
		for enemy in faction.attacker_list:
			if enemy.hold_order_remove:
				pass
			else:
				enemy.hold_range = hold_range * hold_order
				hold_order += 1
	elif state == "add":
		hold_order_remove = false
		var hold_order = 1
		var hold_range = 30
		for enemy in faction.attacker_list:
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

func prone(proned):
	if proned:
		is_prone = true
		anim = "prone_idle"
		get_node("body").set_pos(Vector2(0, 14))
		get_node("body/prone").set_trigger(false)
		get_node("body/standing").set_trigger(true)
		get_node("body/prone").set_pos(get_node("body/legs").get_pos())
		
		get_node("body/legs").set_pos(Vector2(-4, -2))
		get_node("body/legs/secondaryEquip").set_pos(Vector2(14, - 2))
		head.set_pos(Vector2(12, -6))
		arm_r.set_pos(Vector2(-1, -1))
		if headArmour != []:
			headArmour[0].set_pos(Vector2(0, -4))
		if bodyArmour != []:
			bodyArmour[0].set_rotd(-90)
			bodyArmour[0].set_pos(Vector2(2, 0))
		if primaryGun != []:
			primaryGun[0].set_pos(get_node("body/arm_r/Gun").get_pos())
		if secondaryGun != []:
			secondaryGun[0].set_rotd(180)
			secondaryGun[0].set_pos(Vector2(get_node("body/legs/secondaryEquip").get_pos()))
	else:
		is_prone = false
		anim = "idle"
		get_node("body").set_pos(Vector2(0, 0))
		get_node("body/standing").set_trigger(false)
		get_node("body/prone").set_trigger(true)
		get_node("body/standing").set_pos(get_node("body/legs").get_pos())
		
		head.set_pos(Vector2(0, -13))
		get_node("body/legs").set_pos(Vector2(0, 5))
		get_node("body/legs/secondaryEquip").set_pos(Vector2(-5, -20))
		arm_r.set_pos(Vector2(-5, -3))
		if headArmour != []:
			headArmour[0].set_pos(Vector2(0 , -4))
		if bodyArmour != []:
			bodyArmour[0].set_rotd(0)
			bodyArmour[0].set_pos(Vector2(0, -4))
		if secondaryGun != []:
			secondaryGun[0].set_pos(Vector2(get_node("body/legs/secondaryEquip").get_pos()))
			secondaryGun[0].set_rotd(-90)


	flip(flipped)
################################################################################
#fixed processes
#death

#look and move
func go_to(object):
	if is_prone:
		prone(false)
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
	if target_list.front().get_parent().dead:
		untrack(target_list.front())
	else:
		var target = (target_list.front())
		look(target)
		go_to(target)
		if primaryGun != []:
			if get_pos().distance_to(target.get_global_pos()) <= (primaryGun[0].bulletspeed * primaryGun[0].distance) * .95:
				holding = true
				primaryGun[0].aiming(true, faction.enemynumber)
				if attack_ready == true and primaryGun[0].current_clip > 0:
					fire()
		if get_pos().distance_to(target.get_global_pos()) <= 20:
			holding = true
			if attack_ready == true:
				melee()

#movement and animations
func animation():
	if anim != animNew:
		animNew = anim
		animNode.play(anim)
	if armanim != armanimNew:
		armanimNew = armanim
		armanimNode.play(armanim)
		armanim = ""

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
		if abs(velocity.x) < PRONE_SPEED:
			velocity.x += ACCELERATION * flip_mod
		else:
			velocity.x -= DECCELERATION / 2 * sign(velocity.x)
	
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