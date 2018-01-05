extends "res://Data/Basic_infantry.gd"

#var enemies = preload("res://Enemies.tscn").instance()
var scream_delay = 5
var total_scream_delay = 5
var total_scream_time = 5
var scream_time = 5
var scream = false
var spawn = 2

var my_z = 0

var left_leg_gone = false
var right_leg_gone = false

var wait = false
var random
var wait_time_total = 3
var wait_time = 2
#var check_time = 10
var look
var attack_detect

var spawning = false
var opacity = 0.0
var alerted = false
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func spawn_finish():
	spawning = false
	head.get_node("head").set_layer_mask_bit(faction.sidenumber, true)
	get_node("body").set_layer_mask_bit(faction.sidenumber, true)
#	get_node("body").set_collision_mask_bit(faction.enemynumber, true)
	get_node("body/head/head/Area2D").set_collision_mask_bit(faction.enemynumber, true)
	get_node("body/head/head/Area2D").set_collision_mask_bit(faction.enemynumber * 3, true)
	set_z(0)
	start(true)

func start(on):
	if on:
		show()
		get_node("body").set_layer_mask_bit(faction.sidenumber, true)
		get_node("body").add_to_group(faction.side)
		head.get_node("head").set_layer_mask_bit(faction.sidenumber, true)
		get_node("body/head/head/Area2D").set_collision_mask_bit(faction.enemynumber, true)
#		get_node("body/head/head/Area2D").set_collision_mask_bit(faction.enemynumber * 3, true)
#		faction.attacker_list.append(myself)

		get_node("body/head/head/Area2D").connect("body_enter", self, "track")
		get_node("body/head/head/Area2D").connect("body_exit", self, "untrack")
#			orders("patrol")
#			set_fixed_process(true)
		call_deferred("orders", "patrol")
		call_deferred("set_fixed_process", true)
	else:
		call_deferred("set_fixed_process", false)
		hide()
		
func create_new():
	Global.gen.call_deferred("generate_character", self, true)
	arm_l.show()
	arm_r.show()
	leg_l.show()
	leg_r.show()
	head.show()
#	show()

	chase = false
	alerted = false
	target_list = []
	dead = false
	right_arm_gone = false
	left_arm_gone = false
	right_leg_gone = false
	left_leg_gone = false
	effect = null
	objective = null

	WALK_SPEED_TOTAL = rand_range(75, 110.0)
	WALK_SPEED = WALK_SPEED_TOTAL
	health = total_health

	call_deferred("health")
#	faction.attacker_list.append(myself)
	level.loaded_enemies.append(self)
	call_deferred("gun_chance")

#	orders("patrol")
#	set_fixed_process(true)
	
func create():
	if not spawned:
		spawned = true
		universal_start()
		Global.gen.call_deferred("generate_character", self, true)
		aim_penalty = 30
		WALK_SPEED_TOTAL = round(rand_range(75, 110))
		WALK_SPEED = WALK_SPEED_TOTAL
		myself = weakref(self)
		enemy = true
#		level.loaded_enemies.append(myself)
		look = get_node("body/cast")
		attack_detect = get_node("body/attack_detect")
		jump_over = get_node("body/jump")
		jump_l = get_node("jump_r")
		jump_r = get_node("jump_r")
		arm_r = get_node("body/arm_r")
		arm_l = get_node("body/arm_l")
		gun = get_node("body/arm_r/gun")
		head = get_node("body/head")
		leg_l= get_node("body/lower_body/leg_l")
		leg_r= get_node("body/lower_body/leg_r")
		upper_body = get_node("body/upper_body")
		lower_body = get_node("body/lower_body")
		raycast = get_node("RayCast2D")
		fire_ready = get_node("Attack")
		fire_ready.set_wait_time(.5)
		fire_ready.connect("timeout", self, "fireready")
		get_node("hit_timer").connect("timeout", self, "original_colour")
		health_display = get_node("body/head/head/health_meter/health")
		armanimNode = get_node("AnimationPlayer")
#		animNode = get_node("body/legs")
		total_health = 100
		health = total_health
		call_deferred("gun_chance")
		call_deferred("health")
		
#		if get_parent() != null:
#			get_node("body").set_layer_mask_bit(faction.sidenumber, true)
#			get_node("body").add_to_group(faction.side)
#			head.get_node("head").set_layer_mask_bit(faction.sidenumber, true)
#			get_node("body/head/head/Area2D").set_collision_mask_bit(faction.enemynumber, true)
#			get_node("body/head/head/Area2D").set_collision_mask_bit(faction.enemynumber * 3, true)
#			faction.attacker_list.append(myself)
#			orders("patrol")
#			set_fixed_process(true)
		
func gun_chance():
	random = round(rand_range(0, 3))
	if random >= 3:
		var basic_gun = Global.Guns.get_node("Zombie_guns/Rusty_AK").duplicate()
#		var basic_gun = level.loaded_basic_weapons.back()
#		level.loaded_basic_weapons.pop_back()
		basic_gun.Global = Global
		call_deferred("equip", basic_gun, true, "primaryGun")
		basic_gun.call_deferred("generate", "Crud")

		basic_gun.call_deferred("start")

func wait(delta):
	random -= delta
	if random <= 0:
		wait = false

func find_target(target):
	var casting = target.get_global_pos() - self.look.get_global_pos()
	self.look.set_cast_to(Vector2(casting.x * flip_mod, casting.y))
	if self.look.is_colliding():
		if self.look.get_collider() == null:
			pass
		elif self.look.get_collider().is_in_group("players") and not chase:
			chase()
					
func dismember(anatomy, vel):
	var new_limb = Global.limbs.get_node("limb").duplicate()
	if anatomy == arm_r:
		if primaryGun != []:
			dropGun()
	new_limb.set_global_pos(anatomy.get_global_pos())
	new_limb.set_rotd(anatomy.get_rotd())
	var dup = anatomy.duplicate()
#	new_limb.get_parent().remove_child(new_limb)
	new_limb.add_child(dup)
	dup.set_scale(Vector2(flip_mod,1))
	dup.set_pos(Vector2(0,0))
	get_parent().add_child(new_limb)
	new_limb.decap(vel)

	new_limb.get_node("Particles2D").set_param(0, new_limb.get_angle_to(get_node("body").get_global_pos()) - 3.14159/2)
	new_limb.get_node("Particles2D").set_emitting(true)
	anatomy.hide()

func original_colour():
	hit = false
#	if effect == null:
#		arm_r.get_node("bicep").set_modulate(Color(1,1, 1))
#		arm_r.get_node("bicep/forearm").set_modulate(Color(1,1, 1))
#		arm_r.get_node("bicep/forearm/hand").set_modulate(Color(1,1, 1))
#		arm_l.get_node("bicep").set_modulate(Color(1,1, 1))
#		arm_l.get_node("bicep/forearm").set_modulate(Color(1,1, 1))
#		arm_l.get_node("bicep/forearm/hand").set_modulate(Color(1,1, 1))
#		for limb in leg_l.get_children():
#			limb.set_modulate(Color(1,1, 1))
#		for limb in leg_r.get_children():
#			limb.set_modulate(Color(1,1, 1))
#		head.get_node("head/Sprite").set_modulate(Color(1,1, 1))
#		legs.set_modulate(Color(1,1, 1))
#		waist.set_modulate(Color(1,1, 1))
	
#func _draw():
#	if points.size() > 1:
#		for p in points:
#			draw_circle(p - get_global_pos(), 4, Color(1, 0, 0)) # we draw a circle (convert to global position first)
#			
#	
func burning():
		arm_r.get_node("bicep").set_modulate(Color(0,0, 0))
		arm_r.get_node("bicep/forearm").set_modulate(Color(0,0, 0))
		arm_r.get_node("bicep/forearm/hand").set_modulate(Color(0,0, 0))
		arm_l.get_node("bicep").set_modulate(Color(0,0, 0))
		arm_l.get_node("bicep/forearm").set_modulate(Color(0,0, 0))
		arm_l.get_node("bicep/forearm/hand").set_modulate(Color(0,0, 0))
		for limb in leg_l.get_children():
			limb.set_modulate(Color(0,0, 0))
		for limb in leg_r.get_children():
			limb.set_modulate(Color(0,0, 0))
		head.get_node("head/Sprite").set_modulate(Color(0,0, 0))
		legs.set_modulate(Color(0,0, 0))
		waist.set_modulate(Color(0,0, 0))
	
func blue():
#	get_node("hit_timer").start()
	arm_r.get_node("bicep").set_modulate(Color(0,0, 255))
	arm_r.get_node("bicep/forearm").set_modulate(Color(0,0, 255))
	arm_r.get_node("bicep/forearm/hand").set_modulate(Color(0,0, 255))
	arm_l.get_node("bicep").set_modulate(Color(0,0, 255))
	arm_l.get_node("bicep/forearm").set_modulate(Color(0,0, 255))
	arm_l.get_node("bicep/forearm/hand").set_modulate(Color(0,0, 255))
	for limb in leg_l.get_children():
		limb.set_modulate(Color(0,0, 255))
	for limb in leg_r.get_children():
		limb.set_modulate(Color(0,0, 255))
	head.get_node("head/Sprite").set_modulate(Color(0,0, 255))
	legs.set_modulate(Color(0,0, 255))
	waist.set_modulate(Color(0,0, 255))
	
func red():
	if effect == null:
		arm_r.get_node("bicep").set_modulate(Color(255,0, 0))
		arm_r.get_node("bicep/forearm").set_modulate(Color(255,0, 0))
		arm_r.get_node("bicep/forearm/hand").set_modulate(Color(255,0, 0))
		arm_l.get_node("bicep").set_modulate(Color(255,0, 0))
		arm_l.get_node("bicep/forearm").set_modulate(Color(255,0, 0))
		arm_l.get_node("bicep/forearm/hand").set_modulate(Color(255,0, 0))
		for limb in leg_l.get_children():
			limb.set_modulate(Color(255,0, 0))
		for limb in leg_r.get_children():
			limb.set_modulate(Color(255,0, 0))
#		head.get_node("head/Sprite").set_modulate(Color(255,0, 0))
		legs.set_modulate(Color(255,0, 0))
		waist.set_modulate(Color(255,0, 0))

func shocking():
	arm_r.get_node("bicep").set_modulate(Color(5,5, 5))
	arm_r.get_node("bicep/forearm").set_modulate(Color(5,5, 5))
	arm_r.get_node("bicep/forearm/hand").set_modulate(Color(5,5, 5))
	arm_l.get_node("bicep").set_modulate(Color(5,5, 5))
	arm_l.get_node("bicep/forearm").set_modulate(Color(5,5, 5))
	arm_l.get_node("bicep/forearm/hand").set_modulate(Color(5,5, 5))
	for limb in leg_l.get_children():
		limb.set_modulate(Color(5,5, 5))
	for limb in leg_r.get_children():
		limb.set_modulate(Color(5,5, 5))
#	head.set_modulate(Color(5,5, 5))
	legs.set_modulate(Color(5,5, 5))
	waist.set_modulate(Color(5,5, 5))
	
func hit(collider):
#	if collider.get_global_pos().y < collider.get_global_pos().y:
#		print ("critical")
#		collider.damage = collider.damage * 2
	if collider.effect != null and effect == null:
		effect = collider.effect
		if collider.effect == "freeze":
			freeze(collider.effect_multiplier)
		elif collider.effect == "fire":
			burn(collider.effect_multiplier)
		elif collider.effect == "shock":
			shock(collider.effect_multiplier)

#	else:
#		red()
	get_node("hit_timer").start()
	if hit == false:
		knockback_velocity.x = collider.velocity.x * collider.stopping_power
		knockback_velocity.y = collider.velocity.y * collider.stopping_power
	if collider.drop != true and not collider.critical:
		var vel = collider.velocity * collider.stopping_power
		var random = round(rand_range(0, 20))
		if (random == 0 and right_arm_gone == false):
			right_arm_gone = true
			dismember(arm_r, vel)
		elif (random == 1 and left_arm_gone == false):
			left_arm_gone = true
			dismember(arm_l, vel)
		elif (random == 2 and right_leg_gone == false):
			right_leg_gone = true
			dismember(leg_r, vel)
			prone()
		elif (random == 3 and left_leg_gone == false):
			left_leg_gone = true
			dismember(leg_l, vel)
			prone()

	
	hit = true
	if collider.critical:
		health -= collider.damage * 3
	else:
#		dia.damage(collider.damage)
		health -= collider.damage
	

	if health <= 0 and not dead:
		var vel = collider.velocity * collider.stopping_power
		dead = true
		call_deferred("death", vel)

	elif not chase:
		if collider.player != null:
			pass
		elif !collider.player.get_ref():
			pass
		else:
			var pos = collider.player.get_ref().get_global_pos()
			objective = pos
			orders("investigate")
	health()

func free_up():
	call_deferred("start", false)
		

	home_zone.get_ref().enemy_number -= 1
	get_node("body/head/head/Area2D").disconnect("body_enter", self, "track")
	get_node("body/head/head/Area2D").disconnect("body_exit", self, "untrack")
	for child in upper_body.get_node("effects").get_children():
		child.set_emitting(false)

#	level.loaded_enemies.remove(level.loaded_enemies.find(myself))
#	level.loaded_enemies.push_front(myself)
#	faction.attacker_list.remove(faction.attacker_list.find(myself))
	if chase == true:
		level.chase_list.remove(level.chase_list.find(myself))
		
	call_deferred("create_new")
#	start(false)
#	hide()

func loot():
	var loot = Global.resource.get_node("trade").duplicate()
	loot.set_global_pos(get_node("body").get_global_pos())
	loot.trade = round(rand_range(1, 10))
	level.add_child(loot)
	
func death(velocity):
	set_fixed_process(false)
	loot()

	get_node("body").set_layer_mask_bit(faction.sidenumber, false)
	if head != null:
		head.get_node("head").set_layer_mask_bit(faction.sidenumber, false)
	if primaryGun != []:
		dropGun()
	get_node("SamplePlayer2D").play("death")

	var new_limb = Global.limbs.get_node("body").duplicate()
	new_limb.set_global_pos(get_node("body").get_global_pos())
	new_limb.set_rotd(get_node("body").get_rotd())
	var dup = get_node("body").duplicate()
	new_limb.add_child(dup)
#	new_limb.get_parent().remove_child(new_limb)
	dup.set_pos(Vector2(0,0))
	get_parent().call_deferred("add_child", new_limb)

	if velocity != null:
		new_limb.call_deferred("decap", velocity)
	else:
		new_limb.call_deferred("decap", velocity)
	if chase == true:
		level.chase_list.remove(level.chase_list.find(myself))
	home_zone.get_ref().enemy_number -= 1
#	call_deferred("free_up")
	call_deferred("queue_free")
#	free_up()
	
func melee_attack(m):
	var Aimrot = head.get_rot() * flip_mod
	var pos = Vector2(cos(Aimrot), -sin(Aimrot)) * flip_mod
	var spawn_point = get_node("body/head/bite").get_global_pos()
	get_node("SamplePlayer2D").play("bite")
	m = load("res://Attacks.tscn").instance().get_node("melee/Bite").duplicate()
	if flip_mod == -1:
		m.set_scale(Vector2(1 * flip_mod, 1)) 
		m.flip_mod = -1
	m.stopping_power = .5
	m.damage = 1
	get_node("AnimationPlayer").play("Bite")
	fire_ready.set_wait_time(.5)
	m.distance = .3
	m.bulletspeed = 100
	m.set_rot(Aimrot)
	m.set_collision_mask_bit(faction.enemynumber, true)
	fire_ready.start()
	m.set_global_pos(spawn_point)
	faction.add_child(m)
	
#func navigate1(goal):
#	if not moving and grounded:
#		var position = get_global_pos()
#		main_point = goal
#		if abs(main_point.get_global_pos().y - position.y) >= 40:
#			travel = null
#			if main_point.get_global_pos().y + 40 > position.y:
#				for drop in zone.get_node("drops").get_children():
#					if drop.get_global_pos().y > position.y - 30 and drop.get_global_pos().y < position.y + 30:
#						travel = drop
#				for drop in zone.get_node("drops").get_children():
#					if drop.get_global_pos().y > position.y - 30 and drop.get_global_pos().y < position.y + 30 and drop.get_global_pos().distance_to(position) < travel.get_global_pos().distance_to(position):
#						travel = drop
#			if travel != null:
#				moving = true
#				dropping = true
#			elif main_point.get_global_pos().y - 80 < position.y:
#				travel = null
#				for climbs in zone.get_node("climbs").get_children():
#					if (climbs.get_global_pos().y > position.y - 25 and climbs.get_global_pos().y < position.y + 25):
#						travel = climbs
#				for climbs in zone.get_node("climbs").get_children():
#					if ((climbs.get_global_pos().y > position.y - 25 and climbs.get_global_pos().y < position.y + 25) and abs(climbs.get_global_pos().x - position.x) < abs(travel.get_global_pos().x - position.x)):
#						travel = climbs
#				if travel != null:
#					moving = true
#					climbing = true
#


#func climbing():
#	raycast.set_rot(get_angle_to(travel.get_global_pos()) - 3.14159/2)
#	holding = false
#	if travel.get_global_pos().distance_to(get_global_pos()) < 3:
#		holding = true
#		climb = true
#	if velocity.y > -WALK_SPEED and climb == true:
#		grounded = true
#		velocity.y -= ACCELERATION
#	if get_global_pos().y <= travel.get_children().back().get_global_pos().y - 10:
#		velocity.y = -50
#		holding = false
#		climbing = false
#		moving = false
#		climb = false
#		grounded = false
#	elif main_point.get_global_pos().y > get_global_pos().y or travel.get_global_pos().y + 20 < get_global_pos().y:
#		holding = false
#		climbing = false
#		moving = false
#		climb = false
#		grounded = false
#func dropping():
#	raycast.set_rot(get_angle_to(travel.get_global_pos()) - 3.14159/2)
#	if travel.get_global_pos().distance_to(get_global_pos()) < 20:
#		holding = false
#		grounded = false
#	if travel.get_global_pos().y + 20 < get_global_pos().y:
#		dropping = false
#		holding = false
#		moving = false

func chase():
	if chase == false:
		orders("chase")
		level.chase_list.append(myself)

func start_scream(delta):
	if not alerted:
		scream_delay -= delta
		if scream_delay <= 0:
			get_node("AnimationPlayer").play("scream")
			get_node("SamplePlayer2D").play("scream")
			scream = true
			scream_delay = total_scream_delay

func scream(delta):
#		if zone.get_parent().enemy_number <  zone.get_parent().enemy_reinforce: 
#			call_more_enemies()
#		else:
#			scream_time = 0
#		spawn = 2
		
		if not alerted:
			holding = true
			scream_time -= delta
			spawn -= delta
			if spawn <= 0:
				for enemy in faction.attacker_list:
					if check_ref(enemy.get_ref()):
						pass
					elif not enemy.get_ref().alerted:
						enemy.get_ref().alerted = true
					elif not enemy.get_ref().chase: 
	#					if enemy.get_ref().zone == zone:
	#						enemy.get_ref().target_list.append(target_list.front())
	#						enemy.get_ref().call_deferred("chase")
						if abs(get_global_pos().distance_to(enemy.get_ref().get_global_pos())) < 150:
							enemy.get_ref().objective = target_list.front().get_ref().get_global_pos()
							enemy.get_ref().orders("investigate")
#							enemy.get_ref().target_list.append(target_list.front())
#							enemy.get_ref().call_deferred("chase")
				alerted = true
		else:
			scream_time = total_scream_time
			spawn = 1
			scream = false
func call_more_enemies():
	var spawning = zone.get_node("spawns").get_children()[round(rand_range(0, zone.get_node("spawns").get_children().size() - 1))]
	var zombie = Global.enemies.get_node("Zombie_movement").duplicate()
	zombie.home_zone = weakref(zone.get_parent())
	zone.get_parent().enemy_number += 1
	faction.call_deferred('add_child', zombie)
	zombie.set_global_pos(spawning.get_global_pos())
	zombie.target_list.append(target_list.front())
	zombie.level = level
	zombie.call_deferred("chase")
	pass