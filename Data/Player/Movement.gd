extends "res://Data/Basic_infantry.gd"
#var attacks = preload("res://Attacks.tscn")
var I = preload("res://Inventory_hud.tscn").instance()
var h = preload("res://HUD.tscn").instance()
var c = preload("res://Commands.tscn").instance()
var g = preload("res://Explosives.tscn").instance()
var build_mode = preload("res://Build_mode.tscn").instance().duplicate()

var old_zone = null

var basic_gun
var Guns = preload("res://Guns.tscn")
var name = "Shannon"

var money = 50
var reinforcements = 10
var combat = false
#values
var AIMSPEED = .05
var standingorders = "attack"
#display
var total_ammo
var current_ammo
var bullet_list = []
#player restraints
var place = false
var command = false
var windows = false
var inventory = false
var aim = false
#bool
var button
var placing
#holders
var orders
var selected
var Build
var build_mode_dup
#change lanes
#var y = 0
#var up = false
#var down = false
#var lane_dist = 20

var detect
var detect_list = []

#var ladder_engaged
var base_size

func position():
	pass
#	get_node("Camera2D").set_global_pos(Vector2(get_global_pos().x, -get_viewport().get_rect().size.y + 200))
#	get_node("Camera2D").set_limit(1, -get_viewport().get_rect().size.y)
#	base_size = get_viewport().get_rect().size
	
func _ready():
#	base_size = get_viewport().get_rect().size
#	print(str(base_size.y))

	if combat == true:
		combat = false
		windows = false
	else:
		pass
		faction.player_list.append(self)
		get_node("body").set_layer_mask_bit(get_parent().sidenumber, true)
		get_node("body").add_to_group(faction.side)
#		windows = true
	if spawned == false:
		AI = false
		spawned = true
		myself = weakref(self)
		WALK_SPEED = 150.0
		WALK_SPEED_TOTAL = 150.0
		get_viewport().connect("size_changed", self, "position")
		Global = get_node("/root/Global")
#		Global.player = myself
		detect = get_node("Area2D")
		detect.connect("body_enter", self, "detect")
		detect.connect("body_exit", self, "no_detect")
		get_node("Area2D1").connect("body_enter", self, "sight")
		get_node("Area2D1").connect("body_exit", self, "no_sight")
		total_health = 20.0
		set_fixed_process(true)
		set_process_input(true)
		raycast = get_node("raycast")
		arm_r = get_node("body/arm_r")
		head = get_node("body/head")
		jump_l = get_node("jump_l")
		jump_r = get_node("jump_r")
		comment_box = get_node("comment_box")
		comment = get_node("comment_box/comment")
		animNode = get_node("body/legs")
		armanimNode = get_node("AnimationPlayer")
		head = get_node("body/head")
		
		arm_r = get_node("body/arm_r")
		arm_l = get_node("body/arm_l")
		head = get_node("body/head")
#		torso = get_node("body/torso")
		leg_l= get_node("body/leg_l")
		leg_r= get_node("body/leg_r")
		legs = get_node("body/legs")
		waist = get_node("body/waist")
		
		fire_ready = get_node("fire_ready")
		fire_ready.connect("timeout", self, "fireready")
		get_node("hit_timer").connect("timeout", self, "original_colour")
		health = total_health
		orders = c.get_node("Commands")
		call_deferred("hud")
		basic_gun = Guns.instance().get_node("Tier_1/M14").duplicate()
		basic_gun.generate("Tier_1")
		if primaryGun == []:
			equip(basic_gun, true, "primaryGun")
			basic_gun.start()
	health = total_health
	update_hud()
		
		
func build_hud():
	build_mode_dup = build_mode.duplicate()
	build_mode_dup.player = myself
#	build_mode_dup.on_supply_run = Global.on_supply_run
	faction.add_child(build_mode_dup)
	build_mode_dup.start(myself)
	set_process_input(false)

func sight(item):
	if item.is_in_group("darkness"):
		item.set_opacity(.5)
	pass
func no_sight(item):
	if item.is_in_group("darkness"):
		item.set_opacity(1)
	pass

func detect(item):
	if item.is_in_group("darkness"):
		item.set_opacity(0)
	elif item.is_in_group("ammo"):
		if primaryGun[0].current_ammo == primaryGun[0].ammo_capacity:
			pass
		elif primaryGun[0].current_ammo + item.ammo < primaryGun[0].ammo_capacity:
			primaryGun[0].current_ammo += item.ammo
			item.queue_free()
		else:
			primaryGun[0].current_ammo = primaryGun[0].ammo_capacity
			item.queue_free()
	elif item.is_in_group("health"):
		if health == total_health:
			pass
		elif item.health + health > total_health:
			health = total_health
			item.queue_free()
		else:
			health += item.health
			item.queue_free()
		health()
	else:
		if not item in detect_list: 
			detect_list.append(item)

func no_detect(collider):
	if collider.is_in_group("darkness"):
		collider.set_opacity(.5)
	elif detect_list != []:
		if collider in detect_list:
			detect_list.remove(detect_list.find(collider))

func pick_up(item):
	if Global.on_supply_run:
		if Global.supply_run_carry_weight > Global.supply_run_weight + item.weight:
			Global.supply_run_weight += item.weight
			if item.get_parent() != null:
				item.get_parent().remove_child(item)
			Global.supply_run_pack.append(item)
		else:
			comment("Too heavy!")
	else:
		if item.get_parent() != null:
			item.get_parent().remove_child(item)
		Global.pack.append(item)
#	detect_list.remove(detect_list.find(item))
	item.is_equipped = false
	pass

func hud():
	h.get_node("Player1").set_global_pos(Vector2(get_viewport().get_rect().size.x - get_viewport().get_rect().size.x + 50, get_viewport().get_rect().size.y - 75))
	add_child(h)
	health()

func hit(collider):
#	if collider.get_global_pos().y < collider.get_global_pos().y:
#		print ("critical")
#		collider.damage = collider.damage * 2


	if hit == false:
		hit = true
		knockback_velocity.x = collider.velocity.x * collider.stopping_power
		knockback_velocity.y = collider.velocity.y * collider.stopping_power
		health -= collider.damage
		
		if collider.effect != null and effect == null:
			effect = collider.effect
			if collider.effect == "freeze":
				freeze(collider.effect_multiplier)
			elif collider.effect == "fire":
				burn(collider.effect_multiplier)
			elif collider.effect == "shock":
				shock(collider.effect_multiplier)
		elif effect == null:
			red()
		get_node("hit_timer").start()
#	hit = true

#	if health <= 0 and dead == false:
#		dead = true
#		death()

	health()
#func hit(collider):
#	if hit == false:
#		red()
#		knockback_velocity.x = collider.velocity.x * collider.stopping_power
#		knockback_velocity.y = collider.velocity.y * collider.stopping_power
#
#		health -= collider.damage
#		health()
#		hit = true
#		get_node("hit_timer").start()
#		for item in get_node("Area2D").get_overlapping_bodies():
#			detect(item)
func flip_check():
	if raycast.get_rotd() < -90  and flipped == false:
		flipped = true
		flip(true)

	elif raycast.get_rotd() > -90 and flipped == true:
		flipped = false
		flip(false)


	
func health():
	var scale = 100
	if health > 0.0:
		h.get_node("Player1/health_meter/health").set_scale(Vector2((health/total_health) * scale, 1)) 
		if health/total_health > 0.25:
			h.get_node("Player1/health_meter/health").set_modulate(Color(0, 255, 0))
		elif health/total_health <= 0.25:
			h.get_node("Player1/health_meter/health").set_modulate(Color(255, 0, 0))
	else:
		h.get_node("Player1/health_meter/health").set_scale(Vector2(1, 1))
		h.get_node("Player1/health_meter/health").set_modulate(Color(255, 0, 0))


	
func update_hud():
#	if primaryGun != []:
#		total_ammo = primaryGun[0].ammo_capacity
#		current_ammo = primaryGun[0].current_ammo
#	else:
#		total_ammo = 0
#		current_ammo = 0
	h.get_node("Player1").Global = get_node("/root/Global")
	h.get_node("Player1").player = self
	h.get_node("Player1").update_hud()
		
func command(command):
	standingorders = command
	for ally in faction.attacker_list:
		ally.orders(command)
	
func recruit(object):
	faction.points -= object.cost
	windows = false
	object.set_pos(level.get_node("player_1_spawn").get_pos())
	faction.add_child(object)
	object.hold_order("add")

func building(object, build):
	selected = object
	Build = build
	build.structure = selected
	faction.add_child(selected)
	faction.add_child(Build)
	place = true
	
func flip(flipped):
	if flipped:
		flip_mod = -1
	else:
		flip_mod = 1
	get_node("body").set_scale(Vector2(1 * flip_mod, 1))
	head.set_rotd(head.get_rotd() * -1)
	arm_r.set_rotd(arm_r.get_rotd() * -1)
	
#func prone(proned):
#	if proned:
#		get_node("body").set_pos(Vector2(0, -3))
#		get_node("body/prone").set_trigger(false)
#		get_node("body/standing").set_trigger(true)
#						get_node("body/prone").set_pos(get_node("body/legs").get_pos())
#	else:
#		get_node("body").set_pos(Vector2(0, -17))
#		get_node("body/standing").set_trigger(false)
#		get_node("body/prone").set_trigger(true)
#							get_node("body/standing").set_pos(get_node("body/legs").get_pos())
#		
#	if is_prone != true:
#		head.set_pos(Vector2(0, -13))
#		get_node("body/legs").set_pos(Vector2(0, 5))
#		get_node("body/legs/secondaryEquip").set_pos(Vector2(-5, -20))
#		arm_r.set_pos(Vector2(-5, -3))
#		if headArmour != []:
#			headArmour[0].set_pos(Vector2(0 , -4))
#		if bodyArmour != []:
#			bodyArmour[0].set_rotd(0)
#			bodyArmour[0].set_pos(Vector2(0, -4))
#		if secondaryGun != []:
#			secondaryGun[0].set_pos(Vector2(get_node("body/legs/secondaryEquip").get_pos()))
#			secondaryGun[0].set_rotd(-90)
#
#	elif is_prone == true:
#		get_node("body/legs").set_pos(Vector2(-4, -2))
#		get_node("body/legs/secondaryEquip").set_pos(Vector2(14, - 2))
#		head.set_pos(Vector2(12, -6))
#		arm_r.set_pos(Vector2(-1, -1))
#		if headArmour != []:
#			headArmour[0].set_pos(Vector2(0, -4))
#		if bodyArmour != []:
#			bodyArmour[0].set_rotd(-90)
#			bodyArmour[0].set_pos(Vector2(2, 0))
#		if primaryGun != []:
#			primaryGun[0].set_pos(get_node("body/arm_r/Gun").get_pos())
#		if secondaryGun != []:
#			secondaryGun[0].set_rotd(180)
#			secondaryGun[0].set_pos(Vector2(get_node("body/legs/secondaryEquip").get_pos()))
#	get_node("body/headcollision").set_pos(head.get_pos())
#	flip(flipped)
	
		
func _input(event):
	if event.is_action_pressed("grenade") and primaryGun != [] and melee == false: 
		if attack_ready == true and (primaryGun[0].current_ammo - (primaryGun[0].ammo_capacity * primaryGun[0].special_ammo_cost)) >= 0:
			special()
	
	if event.is_action_pressed("inventory"):
		if inventory == false and windows == false:
			I.get_node("inventory").set_global_pos(Vector2(get_viewport_rect().size.x/ 2, get_viewport_rect().size.y/ 4))
			get_viewport().add_child(I)
			I.get_node("inventory").show_inventory(self)
			windows = true
			inventory = true
		elif inventory == true:
			I.get_node("inventory").remove_inventory(self)
			I.get_parent().remove_child(I)
			inventory = false
			windows = false

	elif event.is_action_pressed("command"):
#		print(faction.attacker_list)
#		if command == false and windows == false:
#			command = true
#			orders.set_pos(Vector2(0, -100))
#			if orders.get_parent() != null:
#				orders.get_parent().remove_child(orders)
#			orders.player = self
#			add_child(orders)
#			windows = true
		if windows == false:
			call_deferred("build_hud")
		elif command == true:
			command = false
			orders.get_parent().remove_child(orders)
			windows = false
			
		elif place == true:
			Build.queue_free()
			selected.queue_free()
			place = false
			windows = false
			
		elif inventory == true:
			I.get_node("inventory").remove_inventory(self)
			I.get_parent().remove_child(I)
			inventory = false
			windows = false
		
	if event.is_action_pressed("interact") and detect_list != []:
		detect_list.front().equipped()
		pick_up(detect_list.front())
		if ladder and not ladder_engaged:
			velocity.y = 0
			ladder_engaged = true
		
	if event.is_action_pressed("equip") and detect_list != []:
		detect_list.front().equipped()
		equip(detect_list.front(), true, detect_list.front().slot)
		
	if event.is_action_pressed("reload") and primaryGun != []:
		if reloading == false and attack_ready == true and primaryGun[0].current_clip < primaryGun[0].clip_capacity and primaryGun[0].current_ammo > 0:
			reload()
#		h.get_node("Player1").clear_ammo()
#		h.get_node("Player1").ammo(self)
	elif event.is_action_pressed("switch") and (primaryGun != [] or secondaryGun != []):
		swap()
		
#	elif event.is_action_pressed("fire") and primaryGun != [] and melee == false: 
#		if attack_ready == true and primaryGun[0].current_ammo > 0 and primaryGun[0].current_clip > 0 and primaryGun[0].fullauto == false:
#			fire()
#			update_hud()
#			h.get_node("Player1").shoot(self)

	elif event.is_action_pressed("melee") and melee == false:
		melee()
		
	if event.is_action_pressed("ui_down") and ladder == false:
#		if y > 0 and not down and not up:
#			y -= 1
#			set_z(y)
#			down = true
		if is_prone == false:
			get_node("move").play("prone_idle")
			is_prone = true
#			prone(true)
#			flip(flipped)
#			anim = "prone_idle"

	elif event.is_action_pressed("ui_up"):
#		if y < 3 and not up and not down :
#			y += 1
#			set_z(y)
#			up = true
		if is_prone == true:
			is_prone = false
			get_node("move").play("idle")
#			prone(false)
#			flip(flipped)
		elif jump_l.is_colliding() or jump_r.is_colliding():
			jumping = true
			velocity.y = -JUMP_FORCE/2
			jump_press = 0
	elif event.is_action_released("ui_up") and ladder == false:
		jumping = false
#		
	if event.is_action_pressed("esc"):
		for buildings in faction.building_list:
			buildings.get_ref().resource()
			
func _fixed_process(delta):
	for dark in get_node("Area2D1").get_overlapping_bodies():
		dark.set_opacity(.5)
	for dark in get_node("Area2D").get_overlapping_bodies():
		dark.call_deferred("set_opacity", 0)
	remove_comment(delta)
	gravity_check(delta)
	grounded_check()
#	if up:
#		velocity.y = -80
#		if get_global_pos().y <= -y * lane_dist:
#			velocity.y = 0
#			up = false 
#	if down:
#		velocity.y = 80
#		if get_global_pos().y >= -y * lane_dist:
#			velocity.y = 0
#			down = false 
	
	if windows == false:
		if Input.is_action_pressed("fire") and primaryGun != [] and melee == false and reloading == false: 
			if attack_ready == true and primaryGun[0].fullauto == true and primaryGun[0].current_clip > 0:
				fire()
#				for enemy in zone.get_overlapping_bodies():
#					if enemy.get_parent() == self:
#						pass
#					else:
#						enemy.get_parent().track(get_node("body"))
#						enemy.get_parent().chase()
			elif attack_ready == true and reloading == false and primaryGun[0].current_clip <= 0 and primaryGun[0].current_ammo > 0:
				reload()
	#	if Input.get_joy_axis(0, 1):
	#	arm_r.look_at(Vector2(JOY_ANALOG_0_X, JOY_ANALOG_0_Y))
	#	print (JOY_AXIS_1)
			
	#		
		if Input.is_action_pressed("ui_lookup") and head.get_rotd() <= 45:
			arm_r.rotate(AIMSPEED)
			
		elif Input.is_action_pressed("ui_lookdown") and head.get_rotd() > -45:
			arm_r.rotate(-AIMSPEED)
		if not melee:
			head.set_rot(arm_r.get_rot())
		arm_l.set_rotd(arm_r.get_rotd())
	if Input.is_action_pressed("ui_ctrl") and windows == false:
		WALK_SPEED = 100
		PRONE_SPEED = 50
		primaryGun[0].aiming(true, faction.enemynumberval)
		aim = true
		AIMSPEED = .01
	elif aim == true:
		WALK_SPEED = 200 
		PRONE_SPEED = 50
		AIMSPEED = .05
		aim = false
		primaryGun[0].aiming(false, faction.enemynumberval)
		
	if (jump_press < 0.35) and jumping == true:
		jump_press += delta
		velocity.y -= JUMP_FORCE * 2 * delta

	elif ladder:
		grounded = true
		if Input.is_action_pressed("ui_up") and windows == false:
			if velocity.y > -WALK_SPEED:
				velocity.y -= ACCELERATION
			if velocity.y > 0:
				velocity.y = 0
		elif Input.is_action_pressed("ui_down") and windows == false:
			if velocity.y < WALK_SPEED:
				velocity.y += ACCELERATION
			if velocity.y < 0:
				velocity.y = 0
		else:
			velocity.y = 0
			
	if Input.is_action_pressed("ui_left") and windows == false:
		if flipped == false:
			flip(true)
			flipped = true
			arm_r.set_rot(-arm_r.get_rot())
			head.set_rot(-head.get_rot())
		if not grounded:
			if not is_colliding():
				if velocity.x > -WALK_SPEED:
					velocity.x -= ACCELERATION * acceleration_modifier
		elif not is_prone:
#			anim = "run"
#			get_node("move").play("run")
			if velocity.x > -WALK_SPEED:
				velocity.x -= ACCELERATION
			else:
				velocity.x += DECCELERATION
		elif is_prone:
			if velocity.x > -PRONE_SPEED:
				velocity.x -= ACCELERATION
			else:
				velocity.x += DECCELERATION / 2

	elif Input.is_action_pressed("ui_right") and windows == false:
		if flipped:
			flip(false)
			flipped = false
			arm_r.set_rot(-arm_r.get_rot())
			head.set_rot(-head.get_rot())
		if not grounded:
			if not is_colliding():
				if velocity.x < WALK_SPEED:
					velocity.x += ACCELERATION * acceleration_modifier
		elif not is_prone:
#			anim = "run"
			
			if velocity.x < WALK_SPEED:
				velocity.x += ACCELERATION
			else:
				velocity.x -= DECCELERATION
		elif is_prone:
#			anim = "prone_crawl"
			if velocity.x < PRONE_SPEED:
				velocity.x += ACCELERATION
			else:
				velocity.x -= DECCELERATION / 2
	else:
		if abs(velocity.x) < 5:
			velocity.x = 0
		elif abs(velocity.x) > 0:
			if not grounded:
				velocity.x -=  2 * sign(velocity.x)
			elif is_prone:
				velocity.x -=  DECCELERATION / 2 * sign(velocity.x)
			else:
				velocity.x -= DECCELERATION * sign(velocity.x)
				
	if not is_prone and get_node("crouch").is_colliding():
		prone(true)
	if (Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")) and grounded and not is_prone:
		if not get_node("move").is_playing():
			get_node("move").play("run")
	elif not is_prone:
		get_node("move").play("idle")
	
	if (Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")) and grounded and is_prone:
		if not get_node("move").is_playing():
			get_node("move").play("prone_crawl")
	elif is_prone:
		get_node("move").play("prone_idle")
			
			
	if zone != old_zone:
		var coords = level.get_parent().minimap.get_node("Control/TileMap").map_to_world(Vector2(zone.get_parent().map_coords[0], zone.get_parent().map_coords[1]))
		level.get_parent().minimap.get_node("Control/Sprite").set_pos(coords)
		old_zone = zone
	the_movement(delta)
	knockback()
	animation()
	update_hud()
	if effect != null:
		effect(delta)