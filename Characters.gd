extends KinematicBody2D
#var name = ''
var description = ''
var job = ''
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
var health = 3.0
var total_health = 3.0
var armour = 0
var melee_stopping_power = 3
var remove_comment_time = 0
var velocity = Vector2()
var knockback_velocity = Vector2()
var random_hold = int(rand_range(50, 100))
var random_attack_hold = rand_range(1, .80)
var fight_skill = 0
var labour_skill = 0
var doctor_skill = 0

#orders
var objective
var attacking = false
var defending = false
var placed = false
var attack = false
var follow = false
var hold = false
var retreat = false
var hold_order_remove = false
var patrol = false
var occupy = false

#bools
var equipped
var AI = true
var airborne = false
var spawned = false
var reloading = false
var hit = false
var cast = false
var tracking = false
var flipped = false
var is_prone = false
var left_arm_gone = false
var right_arm_gone = false
var dead = false
var injured = false
var melee = false
var attack_ready = true
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
var building = null

#lists
var myself
var pack = []
var primaryGun = []
var secondaryGun = []
var headArmour = []
var bodyArmour = []
#target lists
var target_list = []
var building_list = []
var low_priority_list = []
var base_priority_list = []
var high_priority_list = []
#side
var side
var holding

#############################################################################
#creating a character
func survivor_creator():
	var name_list = ["Dan", "George", "Norman", "Shannon", "Johnathan", "Patrick", "Mathew", "Alexander"]
	self.name = name_list[int(rand_range(0, name_list.size()))]
	# need male/female
	var random  = int(rand_range(0, 25))
	if random in range(1, 10):
		fighter()
	elif random in range(11, 20):
		labourer()
	elif random in range(21, 25):
		doctor()
	else:
		unskilled()
	
	total_health += fight_skill
#	print (self.name + ", Fight: " +str(fight_skill))
#	print (self.name + ", Labour: " +str(labour_skill))
#	print (self.name + ", Doctor: " +str(doctor_skill))
func fighter():
	fight_skill = int(rand_range(3, 6))
	labour_skill = int(rand_range(1, 4))
	doctor_skill = int(rand_range(1, 4))
	pass
func doctor():
	fight_skill = int(rand_range(1, 4))
	labour_skill = int(rand_range(1, 4))
	doctor_skill = int(rand_range(3, 6))
	pass
func labourer():
	fight_skill = int(rand_range(1, 4))
	labour_skill = int(rand_range(3, 6))
	doctor_skill = int(rand_range(1, 4))
	pass
func unskilled():
	fight_skill = int(rand_range(1, 3))
	labour_skill = int(rand_range(1, 3))
	doctor_skill = int(rand_range(1, 3))
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
	get_node("body/Area2D").set_collision_mask_bit(faction.enemynumber * 3, true)
#hit
func hit(collider):
#	if collider.get_global_pos().y < collider.get_global_pos().y:
#		print ("critical")
#		collider.damage = collider.damage * 2
	get_node("hit_timer").start()
	red()
	if hit == false and not placed:
		knockback_velocity.x = collider.velocity.x * collider.stopping_power
		knockback_velocity.y = collider.velocity.y * collider.stopping_power
	hit = true
	health -= collider.damage
	if health <= 0 and dead == false:
		dead = true
		death()
	health()
	
#melee
func melee():
	attack_ready = false
	melee = true
	fire_ready.stop()
	var m

	if primaryGun != []:
		var spawn_point = arm_r.get_global_pos()
		m = primaryGun[0].melee[0].melee()
		armanim = primaryGun[0].melee_type
		m.damage = primaryGun[0].melee_damage
		m.stopping_power = primaryGun[0].melee_stopping_power + melee_stopping_power
		fire_ready.set_wait_time(.5)
		m.attacker = self
		m.set_layer_mask(faction.enemynumberval)
		fire_ready.start()
		arm_r.add_child(m)
	else:
		melee_attack(m)



	
func special():
	attack_ready = false
	fire_ready.stop()
#	h.get_node("Player1").shoot(self)
	var Aimrot = arm_r.get_rot() * flip_mod
	var pos = Vector2(cos(Aimrot), -sin(Aimrot)) * flip_mod
	var spawn_point = pos + primaryGun[0].get_node("body/special_tip").get_global_pos()

	var bullets = primaryGun[0].special[0].special()
	bullets.damage = primaryGun[0].special_damage
	bullets.stopping_power = primaryGun[0].stopping_power
	bullets.faction = faction
	if flip_mod == -1:
		bullets.get_node("Sprite").set_flip_h(true)  
		bullets.flip_mod = -1
	bullets.set_rotd(rad2deg(Aimrot) + rand_range(primaryGun[0].accuracy, -primaryGun[0].accuracy))
	bullets.set_collision_mask_bit(faction.enemynumber, true)
	bullets.set_pos(spawn_point)
	bullets.side = faction.side
	level.add_child(bullets)
	
	primaryGun[0].special_shoot()
	armanim = "Shoot"
	fire_ready.set_wait_time(primaryGun[0].special_fire_rate)
	fire_ready.start()
	if primaryGun[0].current_clip <= 0 and primaryGun[0].current_ammo > 0:
		reload()

#fire
func fire():
	attack_ready = false
	fire_ready.stop()
#	h.get_node("Player1").shoot(self)
	var Aimrot = arm_r.get_rot() * flip_mod
	var pos = Vector2(cos(Aimrot), -sin(Aimrot)) * flip_mod
	var spawn_point = pos + primaryGun[0].get_node("body/barrel_tip").get_global_pos()

	for bullets in range(primaryGun[0].bullets_inbullets):
		bullets = primaryGun[0].bullettype()
		bullets.faction = faction
		if flip_mod == -1:
			bullets.get_node("Sprite").set_flip_h(true)  
			bullets.flip_mod = -1
		bullets.set_rotd(rad2deg(Aimrot) + rand_range(primaryGun[0].accuracy, -primaryGun[0].accuracy))
		bullets.set_collision_mask_bit(faction.enemynumber, true)
		bullets.set_pos(spawn_point)
		bullets.side = faction.side
		level.add_child(bullets)
	primaryGun[0].shoot()
	armanim = "Shoot"
	fire_ready.set_wait_time(primaryGun[0].fire_rate)
	fire_ready.start()
	if primaryGun[0].current_clip <= 0 and primaryGun[0].current_ammo > 0:
		reload()
 #swap, equip, unequip and drop
func dropGun():
	primaryGun[0].get_parent().remove_child(primaryGun[0])
	fire_ready.stop()
	level.add_child(primaryGun[0])
	primaryGun[0].set_global_pos(get_node("body/arm_r/Gun").get_global_pos())
	primaryGun[0].unlock()
	primaryGun.remove(0)
	
		
func unequip(itemvar):
	itemvar[0].named = str(itemvar[0].name)
	itemvar[0].is_equipped = false
	itemvar[0].queue_free()
	itemvar.pop_front()

func equip(item, pickedup, slot):
	if pickedup == true:
		pack.append(item)
	if item.is_in_group("weapons") and slot == "primaryGun":
		if primaryGun != [] and secondaryGun != []:
			unequip(primaryGun)
			arm_r.add_child(item)
			primaryGun.append(item)
		elif primaryGun != [] and secondaryGun == []:
			primaryGun[0].get_parent().remove_child(primaryGun[0])
			get_node("body/legs").add_child(primaryGun[0])
			arm_r.add_child(item)
			primaryGun.append(item)
			secondaryGun.append(primaryGun[0])
			primaryGun.pop_front()
		else:
			primaryGun.append(item)
			arm_r.add_child(item)
		if primaryGun != []:
			primaryGun[0].set_pos(get_node("body/arm_r/Gun").get_pos())
			primaryGun[0].set_rotd(get_node("body/arm_r/Gun").get_rotd())
		if secondaryGun != []:
			secondaryGun[0].set_pos(get_node("body/legs/secondaryEquip").get_pos())
			secondaryGun[0].set_rot(get_node("body/legs/secondaryEquip").get_rot())
	elif item.is_in_group("weapons") and slot == "secondaryGun":
		if secondaryGun != []:
			unequip(secondaryGun)
		secondaryGun.append(item)
		secondaryGun[0].set_pos(get_node("body/legs/secondaryEquip").get_pos())
		secondaryGun[0].set_rotd(get_node("body/legs/secondaryEquip").get_rotd())
		get_node("body/legs").add_child(secondaryGun[0])
	elif item.is_in_group("armour"):
		if item.is_in_group("head"):
			if headArmour != []:
				headArmour[0].level.remove_child(headArmour[0])
				headArmour[0].unequip(self)
				headArmour.pop_front()
			headArmour.append(item)
			get_node("body/head").add_child(item)
			item.set_pos(Vector2(get_node("body/head").get_pos().x, -4))
			item.set_rot(0)
			headArmour[0].equip(self)
		elif item.is_in_group("body"):
			if bodyArmour != []:
				bodyArmour[0].level.remove_child(bodyArmour[0])
				bodyArmour[0].unequip(self)
				bodyArmour.pop_front()
			bodyArmour.append(item)
			get_node("body/legs").add_child(item)
			item.set_pos(Vector2(get_node("body/legs").get_pos().x, -4))
			item.set_rot(get_node("body/legs").get_rot())
			item.set_rot(0)
			bodyArmour[0].equip(self)
#	if AI:
#		get_node("body/Area2D").set_shape_transform(0, Matrix32( Vector2(300, 300), Vector2(300, 300), Vector2(300, 300) ))
func swap():
	if reloading == true:
		stop_reload()
	if primaryGun != [] and secondaryGun != []:
		secondaryGun.append(primaryGun[0])
		primaryGun.append(secondaryGun[0])
		secondaryGun.pop_front()
		primaryGun.pop_front()
	elif primaryGun == [] and secondaryGun !=[]:
		primaryGun.append(secondaryGun[0])
		secondaryGun.pop_front()
	elif primaryGun != [] and secondaryGun == []:
		secondaryGun.append(primaryGun[0])
		primaryGun.pop_front()
	if primaryGun != []:
		primaryGun[0].get_parent().remove_child(primaryGun[0])
		primaryGun[0].set_pos(get_node("body/arm_r/Gun").get_pos())
		primaryGun[0].set_rotd(get_node("body/arm_r/Gun").get_rotd())
		get_node("body/arm_r").add_child(primaryGun[0])
	if secondaryGun != []:
		secondaryGun[0].get_parent().remove_child(secondaryGun[0])
		secondaryGun[0].set_pos(get_node("body/legs/secondaryEquip").get_pos())
		secondaryGun[0].set_rotd(get_node("body/legs/secondaryEquip").get_rotd())
		get_node("body/legs").add_child(secondaryGun[0])
#reload, stop reloading and fireready
func fireready():
	if melee == true:
		attack_ready = true
		fire_ready.set_wait_time(.5)
		fire_ready.start()
		melee = false
	elif primaryGun != []:
		if reloading == true:
			reloading = false
			primaryGun[0].reload()
		attack_ready = true
		fire_ready.set_wait_time(primaryGun[0].fire_rate)
		fire_ready.start()
		
func stop_reload():
	reloading = false
	fire_ready.set_wait_time(primaryGun[0].reload_speed)
	fire_ready.set_wait_time(primaryGun[0].fire_rate)
	fire_ready.start()
	
func reload():
	reloading = true
	fire_ready.stop()
	fire_ready.set_wait_time(primaryGun[0].reload_speed)
	fire_ready.start()

#que ordering
func hold_order(state):
	pass
#	if state == "remove":
#		hold_order_remove = true
#		var hold_order = 1
#		var hold_range = 30
#		for enemy in faction.attacker_list:
#			if enemy.hold_order_remove:
#				pass
#			else:
#				enemy.hold_range = hold_range * hold_order
#				hold_order += 1
#	elif state == "add":
#		hold_order_remove = false
#		var hold_order = 1
#		var hold_range = 30
#		for enemy in faction.attacker_list:
#			if enemy.hold_order_remove:
#				pass
#			else:
#				enemy.hold_range = hold_range * hold_order
#				hold_order += 1

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
		get_node("body").set_pos(Vector2(0, -3))
		get_node("body/prone").set_trigger(false)
		get_node("body/standing").set_trigger(true)

		get_node("body/legs").set_pos(Vector2(-4, -2))
		get_node("body/legs/secondaryEquip").set_pos(Vector2(14, - 2))
		get_node("body/legs/secondaryEquip").set_rotd(180)
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
			secondaryGun[0].set_rotd(get_node("body/legs/secondaryEquip").get_rotd())
			secondaryGun[0].set_pos(Vector2(get_node("body/legs/secondaryEquip").get_pos()))
	else:
		is_prone = false
		anim = "idle"
		get_node("body").set_pos(Vector2(0, -17))
		get_node("body/standing").set_trigger(false)
		get_node("body/prone").set_trigger(true)
		get_node("body/standing").set_pos(get_node("body/legs").get_pos())
		
		head.set_pos(Vector2(0, -13))
		get_node("body/legs").set_pos(Vector2(0, 5))
		get_node("body/legs/secondaryEquip").set_pos(Vector2(-5, -20))
		get_node("body/legs/secondaryEquip").set_rotd(-90)
		arm_r.set_pos(Vector2(-5, -3))
		if headArmour != []:
			headArmour[0].set_pos(Vector2(0 , -4))
		if bodyArmour != []:
			bodyArmour[0].set_rotd(0)
			bodyArmour[0].set_pos(Vector2(0, -4))
		if secondaryGun != []:
			secondaryGun[0].set_pos(Vector2(get_node("body/legs/secondaryEquip").get_pos()))
			secondaryGun[0].set_rotd(get_node("body/legs/secondaryEquip").get_rotd())
	get_node("body/prone").set_pos(Vector2(0, -2))
	get_node("body/headcollision").set_pos(head.get_pos())
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
	if get_pos().distance_to(object.get_global_pos()) < random_hold :
		holding = true

func look(object):
	if object == null:
		holding = true
	else:
		var obj = object.get_global_pos()
		head.set_rot(get_node("body").get_angle_to(obj) - 3.14159/2)
#		raycast.set_rot(get_angle_to(obj) - 3.14159/2)
#		head.set_rotd(head.get_rotd() * flip_mod)
		arm_r.set_rot(get_node("body").get_angle_to(obj) - 3.14159/2)
#			arm_r.set_rotd(head.get_rotd())
		holding = true

func turret_look(obj):
	head.set_rot(get_angle_to(obj) - 3.14159/2 * flip_mod)
	head.set_rotd(head.get_rotd() * flip_mod)
	arm_r.set_rotd(head.get_rotd() * -1)

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
	if raycast.get_rotd() <= -90  and flipped == false:
		flipped = true
		flip(true)
		jump_over.set_rotd(-90)
	elif raycast.get_rotd() > -90 and flipped == true:
		flipped = false
		flip(false)
		jump_over.set_rotd(90)
		
#targeting and attacking
func attack(targetlist):
	var target = targetlist.front().get_ref()
	if !target:
		targetlist.pop_front()
	elif target.dead:
		targetlist.pop_front()

	else:
		var targeting = target.get_node("body")
		raycast.set_rot(get_angle_to(targeting.get_global_pos()) - 3.14159/2)
		flip_check()
		look(targeting)

		holding = false
		if primaryGun != []:
			if get_pos().distance_to(targeting.get_global_pos()) <= (primaryGun[0].bulletspeed * primaryGun[0].distance) * random_attack_hold:
				holding = true
				primaryGun[0].aiming(true, faction.enemynumberval)
				if attack_ready == true and primaryGun[0].current_clip > 0:
					fire()
			elif targeting.get_global_pos().y < (primaryGun[0].bulletspeed * primaryGun[0].distance) * -random_attack_hold:
				targetlist.pop_front()
		if get_pos().distance_to(targeting.get_global_pos()) < 30:
			holding = true
			if attack_ready == true:
				melee()

func track_closest(targetlist):
	for targets in targetlist:
		if !targets.get_ref():
			targetlist.remove(targetlist.find(targets.get_ref().myself))
		elif get_global_pos().distance_to(targets.get_ref().get_global_pos()) < get_global_pos().distance_to(targetlist.front().get_ref().get_global_pos()):
			targetlist.remove(targetlist.find(targets.get_ref().myself))
			targetlist.push_front(targets.get_ref().myself)
			break

func track(collider):
	if collider.get_parent().myself in target_list or collider.get_parent().myself in building_list or collider.get_parent().myself in low_priority_list:
		pass
	elif collider.get_parent().has_method("initialize"):
		if collider.get_parent().background == true:
			building_list.append(collider.get_parent().myself)
		else:
			target_list.append(collider.get_parent().myself)
	elif collider.get_parent().has_method("repairing") or collider.get_parent().has_method("add_operator"):
		low_priority_list.append(collider.get_parent().myself)
	else:
		target_list.append(collider.get_parent().myself)
		
func untrack(collider):
	if collider.get_parent().myself in target_list:
		target_list.remove(target_list.find(collider.get_parent().myself))
	elif collider.get_parent().myself in building_list:
		building_list.remove(building_list.find(collider.get_parent().myself))
	elif collider.get_parent().myself in low_priority_list:
		low_priority_list.remove(low_priority_list.find(collider.get_parent().myself))
		

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
#	var motion = velocity * delta
	motion = move(motion)
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)