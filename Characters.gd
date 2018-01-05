extends KinematicBody2D
var Global

#var name = ''
var description = ''
var job = ''
#values
var in_motion
var WALK_SPEED = 100.0
var patrol_speed = 50
var WALK_SPEED_TOTAL = 100.0
var PRONE_SPEED = 100
var ACCELERATION = 5
var DECCELERATION = 10
var acceleration_modifier = 0.5
var GRAVITY = 600.0
var JUMP_FORCE = 350
var height = .1
var jump_press = 0
var deathTime = 2
var flip_mod = 1
var hold_order = 1
var hold_range = 30
var health = 3.0
var total_health = 3.0
var armour = 0
var ammo_capacity = 400
var current_ammo = 400
var melee_stopping_power = 3
var remove_comment_time = 0
var velocity = Vector2()
var knockback_velocity = Vector2()
var random_hold = int(rand_range(50, 100))
var random_attack_hold = rand_range(10, 100)
var fight_skill = 0
var labour_skill = 0
var doctor_skill = 0
var carry_weight = 5
var patrol_time = 0
var patrol_hold = false
var enemy = false
var effect = null
var effect_time = 0
var burn_time = 1
var slow_number = 0
var aim_penalty = 20
var stunned = false
var patrol_inturupt_time = 3
var reload_time = 0
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
var investigate = false
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
var ladder = false
var ladder_engaged = false
var grounded = false
var jumping = false
var climbing = false
var dropping = false
var chase = false
var aim = false
var attacking_object = false
#anims
var animNode
var animNew
var anim
var jump_animate = false
var armanim
var armanimNew 
var armanimNode

#parent var
var level 
var faction

#variable nodes
var zone = null
var home_zone
var spawn_home
var comment
var comment_box 
var jump_l
var jump_r
var jump_over
var upper_body
var lower_body
var arm_r
var arm_l
var leg_l
var leg_r
var gun
var waist
var head
var legs
var torso
var zombie
var raycast
var viewarea
var fire_ready
var health_display
var building = null
var reload_clip = null
var m = null

#lists
var myself
var points = []
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
	fight_skill = int(round(rand_range(2, 5)))
	labour_skill =int( round(rand_range(1, 3)))
	doctor_skill = int(round(rand_range(1, 3)))
	pass
func doctor():
	fight_skill = int(round(rand_range(1, 3)))
	labour_skill = int(round(rand_range(2, 5)))
	pass
func labourer():
	fight_skill = int(round(rand_range(1, 3)))
	labour_skill = int(round(rand_range(2, 5)))
	doctor_skill = int(round(rand_range(1, 3)))
	pass
func unskilled():
	fight_skill = int(round(rand_range(1, 3)))
	labour_skill = int(round(rand_range(1, 3)))
	doctor_skill = int(round(rand_range(1, 3)))

func universal_start():
	Global = get_node("/root/Global")
	faction = get_parent()
	level = get_parent().get_parent()
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
	pass
#	get_node("body/head/head/Area2D").set_collision_mask_bit(faction.enemynumber, true)
#	get_node("body/Area2D").set_collision_mask_bit(faction.enemynumber, true)
#	get_node("body/Area2D").set_collision_mask_bit(faction.enemynumber * 3, true)
#hit
func hit(collider):
#	if collider.get_global_pos().y < collider.get_global_pos().y:
#		print ("critical")
#		collider.damage = collider.damage * 2
	red()
	if collider.effect != null and effect == null:
		effect = collider.effect
		if collider.effect == "freeze":
			freeze(collider.effect_multiplier)
		elif collider.effect == "fire":
			burn(collider.effect_multiplier)
		elif collider.effect == "shock":
			shock(collider.effect_multiplier)
	get_node("hit_timer").start()

	if hit == false and not placed:
		knockback_velocity.x = collider.velocity.x * collider.stopping_power
		knockback_velocity.y = collider.velocity.y * collider.stopping_power
	hit = true
	health -= collider.damage
	if health <= 0 and dead == false:
		dead = true
		death(collider)
	health()

func slow(number):
	if number > slow_number:
		slow_number = number
	WALK_SPEED = WALK_SPEED_TOTAL
	if WALK_SPEED - slow_number > 50:
		WALK_SPEED -= slow_number
	else:
		WALK_SPEED = 50
	get_node("move").set_speed(WALK_SPEED/ WALK_SPEED_TOTAL)
	pass
func no_slow(number):
	slow_number -= number
	WALK_SPEED += number
	slow(0)
	pass
	
func effect(delta):
	effect_time -= delta
	if effect == "freeze":
		if effect_time <= 0:
			no_slow(30)
#		elif stunned:
#			blue()
			
	elif effect == "fire":
		burn_time -= delta
		if burn_time <= 0:
			health -= 1
			burn_time = 1
			health()
			if health <= 0 and not dead:
				death(null)

	elif effect == "shock":
		burn_time -= delta
		if burn_time <= 0:
			health -= 1
			burn_time = 1
			if health <= 0 and not dead:
				death(null)
			var random = round(rand_range(0, 100))
			if random > 75:
				stunned = true
			else:
				stunned = false
			
	if stunned:
		if grounded:
			velocity = Vector2()
		target_list = []
	if effect_time <= 0:
		burn_time = 1
		get_node("body/upper_body/effects/burn").set_emitting(false)
		get_node("body/upper_body/effects/shock").set_emitting(false)
		get_node("body/upper_body/effects/freeze").set_emitting(false)
		effect = null
		stunned = false
#		original_colour()
func shock(multiplier):
	effect_time = 5 + multiplier
	var random = round(rand_range(0, 100))
	if random > 75 - multiplier:
#		shocking()
		get_node("body/upper_body/effects/shock").set_emitting(true)
		random = round(rand_range(0, 100))
		if random > 75 - multiplier:
			stunned = true
	else:
		effect = null
func freeze(multiplier):
	effect_time = 5 + multiplier
	get_node("body/upper_body/effects/freeze").set_emitting(true)
	slow(0)
	var random = round(rand_range(0, 100))
	if random > 75 - multiplier:
		stunned = true
#		blue()
		
func burn(multiplier):
	effect_time = 5 + multiplier
	var random = round(rand_range(0, 100))
	if random > 75 - multiplier:
		get_node("body/upper_body/effects/burn").set_emitting(true)
#		burning()
	else:
		effect = null
		
#melee
func melee():
	attack_ready = false
	melee = true
	fire_ready.stop()

#	if primaryGun != []:
#		var spawn_point = arm_r.get_global_pos()
#		m = primaryGun[0].melee[0].melee()
#		armanim = primaryGun[0].melee_type
#		m.player = myself
#		m.damage = primaryGun[0].melee_damage
#		m.stopping_power = primaryGun[0].melee_stopping_power + melee_stopping_power
#		fire_ready.set_wait_time(.5)
#		m.attacker = self
#		m.set_layer_mask(faction.enemynumberval)
#		fire_ready.start()
#		arm_r.add_child(m)
#	else:
	melee_attack(m)



	
func special():
	attack_ready = false
	fire_ready.stop()
#	h.get_node("Player1").shoot(self)
	var Aimrot = arm_r.get_rot() * flip_mod
	var pos = Vector2(cos(Aimrot), -sin(Aimrot)) * flip_mod
	var spawn_point = pos + primaryGun[0].get_node("body/special_tip").get_global_pos()

	var bullets = primaryGun[0].special[0].special()
	bullets.effect = primaryGun[0].mod[0].effect
	bullets.effect_multiplier = primaryGun[0].mod[0].effect_multiplier
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

func aim_penalty():
	var number = aim_penalty
	if abs(velocity.x) < 10 and grounded:
		number -= 10
	if is_prone:
		number -= 5
	if aim:
		number -= 5
	return number
		
	pass
#fire
func fire():
	attack_ready = false
	fire_ready.stop()
#	h.get_node("Player1").shoot(self)
	var Aimrot = arm_r.get_rot() * flip_mod
	var pos = Vector2(cos(Aimrot), -sin(Aimrot)) * flip_mod
	var spawn_point
	if arm_r.get_node("can_shoot").is_colliding():
		spawn_point = arm_r.get_node("can_shoot").get_collision_point()
	else:
		spawn_point = pos + primaryGun[0].get_node("body/barrel_tip").get_global_pos()

	for bullet in range(primaryGun[0].bullets_inbullets):
		var bullets = primaryGun[0].bullettype()
		bullets.faction = faction
		bullets.player = myself
		if flip_mod == -1:
			bullets.get_node("Sprite").set_flip_h(true)  
			bullets.flip_mod = -1
		var aim = aim_penalty()
		bullets.set_rotd(rad2deg(Aimrot) + rand_range(primaryGun[0].accuracy + aim, -primaryGun[0].accuracy - aim))
		bullets.set_collision_mask_bit(faction.enemynumber, true)
		bullets.set_pos(spawn_point)
		bullets.side = faction.side
		faction.add_child(bullets)
	primaryGun[0].shoot()
	get_node("AnimationPlayer").play("Shoot")
	fire_ready.set_wait_time(primaryGun[0].fire_rate)
	fire_ready.start()
	if primaryGun[0].current_clip <= 0:
		reload()
 #swap, equip, unequip and drop
func dropGun():
	attack_ready = false
#	if melee:
#		m.queue_free()
	if reloading:
		stop_reload()
#	reloading = false
	fire_ready.stop()
	fire_ready.set_wait_time(.5)
	fire_ready.start()
	primaryGun[0].drop()
	primaryGun = []

		
func unequip(itemvar):
#	itemvar[0].named = str(itemvar[0].name)
	itemvar[0].is_equipped = false
	itemvar[0].get_parent().remove_child(itemvar[0])
	itemvar.pop_front()

func unequip_change(slot):
	if slot == "primaryGun":
		primaryGun.pop_front()
	elif slot == "secondaryGun":
		secondaryGun.pop_front()
	elif slot == "headArmour":
		headArmour.pop_front()
	elif slot == "bodyArmour":
		bodyArmour.pop_front()
#	itemvar[0].named = str(itemvar[0].name)
#	itemvar[0].is_equipped = false
#	itemvar[0].get_parent().remove_child(itemvar[0])
#	itemvar.pop_front()

func equip(item, pickedup, slot):
	item.level = level
	if pickedup == true:
		if not AI:
			self.pack.append(item)
		item.equipped()
#		if Global.on_supply_run:
#			Global.supply_run_weight -= item.weight
		if item.get_parent() != null:
			item.get_parent().remove_child(item)
	if item.is_in_group("Weapons") and slot == "primaryGun":
		if AI:
			if primaryGun != []:
				unequip(primaryGun)
			gun.add_child(item)
			primaryGun.append(item)
		else:
			if primaryGun != [] and secondaryGun != []:
				unequip(primaryGun)
				arm_r.add_child(item)
				primaryGun.append(item)
			elif primaryGun != [] and secondaryGun == []:
				primaryGun[0].get_parent().remove_child(primaryGun[0])
				get_node("body/upper_body").add_child(primaryGun[0])
				gun.add_child(item)
				primaryGun.append(item)
				secondaryGun.append(primaryGun[0])
				primaryGun.pop_front()
			else:
				primaryGun.append(item)
				gun.add_child(item)
		if primaryGun != []:
			primaryGun[0].set_pos(Vector2(0,0))
			primaryGun[0].set_rotd(gun.get_rotd())
		if secondaryGun != []:
			secondaryGun[0].set_pos(get_node("body/upper_body/secondaryEquip").get_pos())
			secondaryGun[0].set_rot(get_node("body/upper_body/secondaryEquip").get_rot())
	elif item.is_in_group("Weapons") and slot == "secondaryGun":
		if secondaryGun != []:
			unequip(secondaryGun)
		secondaryGun.append(item)
		secondaryGun[0].set_pos(get_node("body/upper_body/secondaryEquip").get_pos())
		secondaryGun[0].set_rotd(get_node("body/upper_body/secondaryEquip").get_rotd())
		get_node("body/upper_body").add_child(secondaryGun[0])
	elif item.is_in_group("Armour"):
		if item.is_in_group("head"):
			if headArmour != []:
#				headArmour[0].get_parent().remove_child(headArmour[0])
				headArmour[0].unequip(headArmour)
				headArmour.pop_front()
			headArmour.append(item)
			get_node("body/head").add_child(item)
			item.set_pos(Vector2(get_node("body/head").get_pos().x, -4))
			item.set_rot(0)
			headArmour[0].equip(self)
		elif item.is_in_group("body"):
			if bodyArmour != []:
#				bodyArmour[0].get_parent().remove_child(bodyArmour[0])
				bodyArmour[0].unequip(headArmour)
				bodyArmour.pop_front()
			bodyArmour.append(item)
			get_node("body/upper_body").add_child(item)
			item.set_pos(Vector2(get_node("body/upper_body").get_pos().x, -4))
			item.set_rot(get_node("body/upper_body").get_rot())
			item.set_rot(0)
			bodyArmour[0].equip(self)
	item.is_equipped = true
	item.player = self

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
		arm_r.get_node("can_shoot").set_cast_to(Vector2(primaryGun[0].get_node("body/barrel_tip").get_pos().x, 0))
		arm_r.get_node("shoot_collider_bottom").set_cast_to(Vector2(primaryGun[0].get_node("body/barrel_tip").get_pos().x, 0))
		get_node("body/can_shoot").set_cast_to(Vector2(primaryGun[0].get_node("body/barrel_tip").get_pos().x, 0))
#		print (arm_r.get_node("can_shoot").get_cast_to())
		primaryGun[0].aiming(false, 0)
		primaryGun[0].get_parent().remove_child(primaryGun[0])
		primaryGun[0].set_pos(Vector2(0, 0))
		primaryGun[0].set_rotd(gun.get_rotd())
		gun.add_child(primaryGun[0])
	if secondaryGun != []:
		secondaryGun[0].aiming(false, 0)
		secondaryGun[0].get_parent().remove_child(secondaryGun[0])
		secondaryGun[0].set_pos(get_node("body/upper_body/secondaryEquip").get_pos())
		secondaryGun[0].set_rotd(get_node("body/upper_body/secondaryEquip").get_rotd())
		get_node("body/upper_body").add_child(secondaryGun[0])
#reload, stop reloading and fireready
func fireready():
	if melee == true:
		attack_ready = true
#		if primaryGun != []:
#			fire_ready.set_wait_time(primaryGun[0].fire_rate)
#		else:
		fire_ready.set_wait_time(.5)
		fire_ready.start()
		melee = false
	elif primaryGun != []:
		if reloading == true:
			if not AI:
				var dia = Global.Float.duplicate()
				dia.set_global_pos(Vector2(get_node("body").get_global_pos().x, get_node("body").get_global_pos().y - 10))
				level.add_child(dia)
				dia.reloaded()
				hud_flash_orange()
			primaryGun[0].clip[0].show()
			primaryGun[0].clip_gone = false
			reloading = false
			primaryGun[0].reload()
			get_node("AnimationPlayer").set_speed(1)
			get_node("AnimationPlayer").play("shoot_hands")
			reload_clip.free()
			reload_clip = null
			if not AI:
				for item in get_node("Area2D").get_overlapping_bodies():
					detect(item)
		attack_ready = true
		fire_ready.set_wait_time(primaryGun[0].fire_rate)
		fire_ready.start()
	else:
		attack_ready = true
		fire_ready.set_wait_time(.5)
		fire_ready.start()
		
func stop_reload():
	reloading = false
	if reload_clip != null:
		reload_clip.free()
		reload_clip = null
	get_node("AnimationPlayer").set_speed(1)
	get_node("AnimationPlayer").play("shoot_hands")
	reload_time = primaryGun[0].reload_speed
	
#	fire_ready.set_wait_time(primaryGun[0].fire_rate)
#	fire_ready.start()

func reloading(delta):
	if reloading:
		if not get_node("AnimationPlayer").is_playing():
			get_node("AnimationPlayer").set_speed(1.0/primaryGun[0].reload_speed)
			get_node("AnimationPlayer").play("reload")
		reload_time -= delta
		if reload_time <= 3.3/primaryGun[0].reload_speed:
			reload_time = 200
			arm_r.get_node("bicep/forearm/hand").add_child(reload_clip)
			reload_clip.set_pos(Vector2(6,0))
			reload_clip.show()
	pass
func reload():
	if not AI:
		var dia = Global.Float.duplicate()
		dia.set_global_pos(Vector2(get_node("body").get_global_pos().x, get_node("body").get_global_pos().y - 10))
		level.add_child(dia)
		dia.reloading()
	reloading = true
	if primaryGun[0].current_clip > 1:
		current_ammo += primaryGun[0].current_clip -1
		primaryGun[0].current_clip = 1
	else:
		current_ammo += primaryGun[0].current_clip
		primaryGun[0].current_clip = 0
	reload_time = primaryGun[0].reload_speed
	reload_clip = primaryGun[0].clip[0].duplicate()
	if not primaryGun[0].clip_gone:
		primaryGun[0].clip_gone = true
		var new_body = Global.limbs.get_node("clip").duplicate()
		var old_clip = primaryGun[0].clip[0]
		var dup = old_clip.duplicate()
		new_body.set_global_pos(old_clip.get_global_pos())
		new_body.set_rotd(old_clip.get_rotd())
#		new_body.get_parent().remove_child(new_body)
		new_body.add_child(dup)
		dup.set_pos(Vector2(0,0))
		dup.set_scale(Vector2(flip_mod,1))
		new_body.velocity = velocity/ 100
		get_parent().add_child(new_body)
		old_clip.hide()
		new_body.decap(null)
		
	fire_ready.stop()
	fire_ready.set_wait_time(primaryGun[0].reload_speed)
	fire_ready.start()

#que ordering


func patrol(delta):
#	reset()

#	WALK_SPEED = 50
	patrol_inturupt_time -= delta
	if patrol_inturupt_time <= 0:
		patrol_inturupt_time = rand_range(3, 10)
		var random = round(rand_range(1, 5))
		if random == 1:
			patrol_hold = true
#			flip_mod *= -1
			raycast.set_rotd(raycast.get_rotd() * -1)
			orders("patrol")
		elif random >= 2:
			patrol_hold = false
#		elif random in range(3, 10):
#			patrol_hold = false
#			raycast.set_rot(get_angle_to(points[1]) - 3.14159/2)
	
	patrol_time -= delta
	if patrol_time <= 0:
		patrol_time = rand_range(60, 120)
		var patrol_route = home_zone.get_ref().get_node("patrols").get_children()[round(rand_range(0, home_zone.get_ref().get_node("patrols").get_children().size()-1))]
		objective = patrol_route.get_children()[round(rand_range(0, patrol_route.get_children().size()-1))]
	if get_global_pos().distance_to(objective.get_global_pos()) < 20:
		if objective.get_parent().get_children().find(objective) == objective.get_parent().get_children().size()- 1:
			objective = objective.get_parent().get_children().front()
		else:
			objective = objective.get_parent().get_children()[objective.get_parent().get_children().find(objective) + 1]
#		
#		raycast.set_rot(get_angle_to(points[1]) - 3.14159/2)
	navigate(objective.get_global_pos())
	if patrol_hold:
		holding = true
	else:
		holding = false

#	else:
#	if zone != null:
#		if zone.get_node("positions").get_children().front().get_global_pos().x > get_global_pos().x:
#			flip_mod = 1
#			raycast.set_rotd(90 * flip_mod)
#			orders("patrol")
#		elif zone.get_node("positions").get_children().back().get_global_pos().x < get_global_pos().x:
#			flip_mod = -1
#			raycast.set_rotd(90 * flip_mod)
#			orders("patrol")
		
func reset():
	arm_r.set_rotd(0)
	head.set_rotd(0)
	
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
func prone():
	if is_prone == false:
		get_node("move").play("prone_idle")
		is_prone = true
		get_node("prone").set_trigger(false)
		get_node("standing").set_trigger(true)
		jump_over.set_enabled(false)

func Jump():
	if is_prone == true:
		pass
#		player.prone(false)
#		player.flip(flipped)
	elif grounded:
		get_node("move").set_speed(1)
		jumping = true
		jump_animate = true
		get_node("move").play("jump_up")
		velocity.y = -JUMP_FORCE/2
		jump_press = 0

#func prone(proned):
#	if proned:
#		is_prone = true
#		anim = "prone_idle"
#		get_node("body").set_pos(Vector2(0, -3))
#		get_node("body/prone").set_trigger(false)
#		get_node("body/standing").set_trigger(true)
#		get_node("prone").set_trigger(false)
#		get_node("standing").set_trigger(true)
#		get_node("body/upper_body").set_pos(Vector2(-4, -2))
#		get_node("body/upper_body/secondaryEquip").set_pos(Vector2(14, - 2))
#		get_node("body/upper_body/secondaryEquip").set_rotd(180)
#		head.set_pos(Vector2(12, -6))
#		arm_r.set_pos(Vector2(-1, -1))
#		if headArmour != []:
#			headArmour[0].set_pos(Vector2(0, -4))
#		if bodyArmour != []:
#			bodyArmour[0].set_rotd(-90)
#			bodyArmour[0].set_pos(Vector2(2, 0))
#		if primaryGun != []:
#			primaryGun[0].set_pos(get_node("body/arm_r/gun").get_pos())
#		if secondaryGun != []:
#			secondaryGun[0].set_rotd(get_node("body/upper_body/secondaryEquip").get_rotd())
#			secondaryGun[0].set_pos(Vector2(get_node("body/upper_body/secondaryEquip").get_pos()))
#	else:
#		is_prone = false
#		anim = "idle"
#		get_node("body").set_pos(Vector2(0, -17))
#		get_node("body/standing").set_trigger(false)
#		get_node("body/prone").set_trigger(true)
#		get_node("standing").set_trigger(false)
#		get_node("prone").set_trigger(true)
#		get_node("body/standing").set_pos(get_node("body/upper_body").get_pos())
#		
#		head.set_pos(Vector2(0, -13))
#		get_node("body/upper_body").set_pos(Vector2(0, 5))
#		get_node("body/upper_body/secondaryEquip").set_pos(Vector2(-5, -20))
#		get_node("body/upper_body/secondaryEquip").set_rotd(-90)
#		arm_r.set_pos(Vector2(-5, -3))
#		if headArmour != []:
#			headArmour[0].set_pos(Vector2(0 , -4))
#		if bodyArmour != []:
#			bodyArmour[0].set_rotd(0)
#			bodyArmour[0].set_pos(Vector2(0, -4))
#		if secondaryGun != []:
#			secondaryGun[0].set_pos(Vector2(get_node("body/upper_body/secondaryEquip").get_pos()))
#			secondaryGun[0].set_rotd(get_node("body/upper_body/secondaryEquip").get_rotd())
#	get_node("body/prone").set_pos(Vector2(0, -2))
#	get_node("body/headcollision").set_pos(head.get_pos())
#	flip(flipped)
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
#	var obj = object.get_global_pos()
	head.set_rot(get_node("body").get_angle_to(object) - 3.14159/2)
	arm_r.set_rot(get_node("body").get_angle_to(object) - 3.14159/2)

func turret_look(obj):
	head.set_rot(get_angle_to(obj) - 3.14159/2 * flip_mod)
	head.set_rotd(head.get_rotd() * flip_mod)
	arm_r.set_rotd(head.get_rotd() * -1)

#movement checks
func gravity_check(delta):
	if not grounded:
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
		if grounded:
			velocity.x = 0
	elif raycast.get_rotd() > -90 and flipped == true:
		flipped = false
		flip(false)
		if grounded:
			velocity.x = 0
		
#targeting and attacking
func check_ref(target):
	if !target:
		return true
	elif target.dead:
		return true
	elif target == null:
		return true
	else:
		return false

func can_attack():
	pass
func attack(target):
	holding = false
	var can_attack = false
	if not target.get_parent().is_in_group("players"):
		if not jump_over.is_colliding():
			target_list.pop_front()
		elif not jump_over.get_collider().get_parent().is_in_group("players"):
			can_attack = true
			
	var casting = target.get_global_pos() - self.attack_detect.get_global_pos()
	self.attack_detect.set_cast_to(Vector2(casting.x * flip_mod, casting.y))
	self.attack_detect.force_raycast_update()
	if self.attack_detect.is_colliding() or attacking_object:
		if self.attack_detect.get_collider() == target:
			can_attack = true
	if can_attack:
		var hit_it = false
		if jump_over.is_colliding():
			if jump_over.get_collider() == target:
				hit_it = true
		if get_pos().distance_to(target.get_global_pos()) < 30 :
			hit_it = true
		if hit_it == true:
			if grounded:
				holding = true
			raycast.set_rot(get_angle_to(target.get_global_pos()) - 3.14159/2)
			look(target.get_global_pos())
			flip_check()
			if attack_ready == true:
				call_deferred("melee")
		elif primaryGun != []:
			if get_node("body").get_global_pos().distance_to(target.get_global_pos()) <= (primaryGun[0].distance) - random_attack_hold:
				if grounded:
					holding = true
				raycast.set_rot(get_angle_to(target.get_global_pos()) - 3.14159/2)
				look(target.get_global_pos())
				flip_check()
				primaryGun[0].aiming(true, faction.enemynumberval)
				if attack_ready == true and primaryGun[0].current_clip > 0:
					call_deferred("fire")
		if defending:
			holding = true
	
func track_closest(targetlist):
	var number = 0
	if check_ref(target_list.front().get_ref()):
		target_list.pop_front()
	else:
		for targets in targetlist:
			if check_ref(targets.get_ref()):
				pass
			elif get_global_pos().distance_to(targets.get_ref().get_global_pos()) < get_global_pos().distance_to(targetlist.front().get_ref().get_global_pos()) -50:
				targetlist.remove(targetlist.find(targets.get_ref().myself))
				targetlist.push_front(targets.get_ref().myself)
			number += 1

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
	if not chase:
		if collider.get_parent().myself in target_list:
			target_list.remove(target_list.find(collider.get_parent().myself))
		elif collider.get_parent().myself in building_list:
			building_list.remove(building_list.find(collider.get_parent().myself))
		elif collider.get_parent().myself in low_priority_list:
			low_priority_list.remove(low_priority_list.find(collider.get_parent().myself))
		
	if target_list == []:
		orders("patrol")
#movement and animations

func animate():
	if grounded:
		get_node("move").set_speed(WALK_SPEED/ WALK_SPEED_TOTAL)
		if abs(velocity.x) > 5 and not holding and grounded and not is_prone:
			if not get_node("move").is_playing():
				get_node("move").play("run")
		elif not is_prone:
			get_node("move").play("idle")
		if abs(velocity.x) > 5 and not holding and grounded and is_prone:
			if not get_node("move").is_playing():
				get_node("move").play("prone_crawl")
		elif is_prone:
			get_node("move").play("prone_idle")
	elif not grounded and not jumping and velocity.y > 0 and jump_animate and not is_prone:
		get_node("move").play("jump_down")
		jump_animate = false
	if stunned:
		if is_prone:
			get_node("move").play("prone_idle")
		else:
			get_node("move").play("idle")

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

	elif not grounded:
		if abs(velocity.x) < WALK_SPEED:
			velocity.x += ACCELERATION * flip_mod * acceleration_modifier

	elif not is_prone:
		if sign(velocity.x) != sign(flip_mod):
			velocity.x = 1 * flip_mod
		if abs(velocity.x) < WALK_SPEED:
			velocity.x += ACCELERATION * flip_mod
		else:
			velocity.x -= DECCELERATION * sign(velocity.x)
	elif is_prone:
		if abs(velocity.x) < WALK_SPEED/2:
			velocity.x += ACCELERATION * flip_mod
		else:
			velocity.x -= DECCELERATION / 2 * sign(velocity.x)
	
func jumping(delta, height):
	if jumping:
		if (jump_press < height):
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

func navigate(target):
	# refresh the points in the path
#	print((str(target) + "global: " + str(get_global_pos())) )
	if target.y > get_global_pos().y + 5 and not jumping:
		points = zone.get_parent().get_node("Navigation2D1").get_simple_path(get_global_pos(), target, true)
	else:
		points = zone.get_parent().get_node("Navigation2D").get_simple_path(get_global_pos(), target, true)
		# if the path has more than one point
#	update()

	if not jumping:
		height = .1
		JUMP_FORCE = 350
		if points.size() > 2:
			if points[2].distance_to(points[1]) >= 50:
				height = .13
			elif points[2].distance_to(points[1]) >= 40:
				height = .09
			elif points[2].distance_to(points[1]) >= 30:
				height = .06
			elif points[2].distance_to(points[1]) > 15:
				height = .04
			elif points[2].distance_to(points[1]) <= 15:
				JUMP_FORCE = 300
				height = .0
				

#		raycast.set_rot(get_angle_to(points[1]) - 3.14159/2)
	if points.size() > 3:
		if not jumping and grounded:
			if points[2].y <= points[1].y and points[1].x > get_global_pos().x and points[2].x > get_global_pos().x and points[3].x > get_global_pos().x and get_global_pos().distance_to(points[1]) < 10 and velocity.x > 20:
					velocity.x = 100
					Jump()
			elif points[2].y <= points[1].y and points[1].x < get_global_pos().x and points[2].x < get_global_pos().x and points[3].x < get_global_pos().x and get_global_pos().distance_to(points[1]) < 10 and velocity.x < -20:
					velocity.x = -100
					Jump()
			elif abs(points[1].x - get_global_pos().x) > 20:
				raycast.set_rot(get_angle_to(points[1]) - 3.14159/2)


	elif points.size() > 2:
		if not jumping and grounded:
			if points[2].y <= points[1].y and points[2].x > get_global_pos().x and points[1].x > get_global_pos().x and abs(get_global_pos().distance_to(points[1])) < 10 and velocity.x > 20:
					velocity.x = 100
					Jump()
			elif points[2].y <= points[1].y and points[2].x < get_global_pos().x and points[1].x < get_global_pos().x and abs(get_global_pos().distance_to(points[1])) < 10 and velocity.x < -20:
					velocity.x = -100
					Jump()
			elif abs(points[1].x - get_global_pos().x) > 20:
				raycast.set_rot(get_angle_to(points[1]) - 3.14159/2)
				
	elif points.size() > 1:
		look(target)
		raycast.set_rot(get_angle_to(target) - 3.14159/2)
		if get_global_pos().distance_to(points[1]) > 2000:
			death(null)
#		if not jumping and target.jumping and grounded:
#			Jump()
	if jump_over.is_colliding():
		if get_node("body/jump").get_collider().is_in_group("wall"):
			target_list.push_front(get_node("body/jump").get_collider().get_parent().myself)
		else:
			Jump()


func the_movement(delta):
	var motion = velocity * delta + knockback_velocity
#	var motion = velocity * delta
	motion = move(motion)
	if is_colliding():
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)