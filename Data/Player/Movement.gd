extends "res://Data/Basic_infantry.gd"

var inv = preload("res://Inventory_hud.tscn").instance()
var hud = preload("res://HUD.tscn").instance()
var c = preload("res://Commands.tscn").instance()
var g = preload("res://Explosives.tscn").instance()
var pause = preload("res://pause.tscn").instance()
var h
var I

var crouching = false
var standing = false

var display = null

var player_hud_pos = 0
var joy = 0
var pl = ""
var controller = true
var old_zone = null
var melee_initial_pos = null
var melee_ready = false
var melee_time = .2
var melee_attack_time = .2
var melee_list = []
var melee_attack = false
var walk_right = false
var walk_left = false
var melee_swing = false
var melee_stab = false
var aiming = false
var fire = false
var basic_gun
var name = "Shannon"



var left_arm_in_use = false
#values
var walk_slow = false
var original_walk_speed = 0
var AIMSPEED = .05
var standingorders = "attack"

#display
var bullet_list = []

#player restraints
var place = false
var command = false
var windows = false
var inventory = false

var deploying = false

#bool
var button
var placing

#holders
var orders
var selected
var Build
#var build_mode_dup
var structure = null
var construction = null

var detect
var detect_list = []
var base_size

var bonus_health = 10.0

var poison = 0.0
var poison_total = 10.0
var in_building = true
var trade = 30
var food = 10
var medicine = 5
var pack = []
var quick_use = [[],[],[],[],[]]

func position():
	pass
#	get_node("Camera2D").set_global_pos(Vector2(get_global_pos().x, -get_viewport().get_rect().size.y + 200))
#	get_node("Camera2D").set_limit(1, -get_viewport().get_rect().size.y)
#	base_size = get_viewport().get_rect().size

func _ready():
#	print(Input.is_joy_button_pressed())
	close()
#	dead = true
	faction.player_list.append(self)
	get_node("body").set_layer_mask_bit(get_parent().sidenumber, true)
	get_node("body").add_to_group(faction.side)
	if spawned == false:
		AI = false
		spawned = true
		myself = weakref(self)
		universal_start()
		Global.gen.generate_character(self, false)
#		pack.append(Global.resource.get_node("scrap").duplicate())
		WALK_SPEED_TOTAL = 150.0
		WALK_SPEED = WALK_SPEED_TOTAL
		get_viewport().connect("size_changed", self, "position")
		detect = get_node("Area2D")
		detect.connect("body_enter", self, "detect")
		detect.connect("body_exit", self, "no_detect")
		get_node("Area2D1").connect("body_enter", self, "sight")
		get_node("Area2D1").connect("body_exit", self, "no_sight")
		total_health = 100.0
		health = total_health
#		raycast = get_node("raycast")
		arm_r = get_node("body/arm_r")
		arm_l = get_node("body/arm_l")
		head = get_node("body/head")
		jump_l = get_node("jump_l")
		jump_r = get_node("jump_r")
		comment_box = get_node("comment_box")
		comment = get_node("comment_box/comment")
		leg_l= get_node("body/lower_body/leg_l")
		leg_r= get_node("body/lower_body/leg_r")
		gun = get_node("body/arm_r/gun")
		upper_body = get_node("body/upper_body")
		fire_ready = get_node("fire_ready")
		fire_ready.connect("timeout", self, "fireready")
		get_node("hit_timer").connect("timeout", self, "original_colour")
		orders = c.get_node("Commands")
		call_deferred("hud")
		I = inv.duplicate()
		I.get_node("inventory").player = self
		set_fixed_process(true)
		set_process_input(true)

		if primaryGun == []:
			basic_gun = Global.Guns.get_node("Tier_1/M14").duplicate()
			basic_gun.Global = Global
			equip(basic_gun, true, "primaryGun")
			basic_gun.generate("Tier_1")
			basic_gun.start()
	call_deferred("update_hud")

#func build_hud():
#	build_mode_dup = build_mode.duplicate()
#	build_mode_dup.player = myself
#	build_mode_dup.on_supply_run = Global.on_supply_run
#	faction.add_child(build_mode_dup)
#	build_mode_dup.start(myself)
#	set_process_input(false)

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
	elif item.is_in_group("trade"):
		trade += item.trade
		
		var dia = Global.Float.duplicate()
		dia.set_global_pos(Vector2(get_node("body").get_global_pos().x, get_node("body").get_global_pos().y - 10))
		level.add_child(dia)
		dia.trade(item.trade)
		
		item.gravitate(myself)
	elif item.is_in_group("food"):
		food += item.food
		item.gravitate(myself)
	elif item.is_in_group("medicine"):
		medicine += item.medicine
		item.gravitate(myself)
	elif item.is_in_group("ammo"):
		if current_ammo == ammo_capacity:
			pass
		elif current_ammo + item.ammo < ammo_capacity:
			current_ammo += item.ammo
			
			var dia = Global.Float.duplicate()
			dia.set_global_pos(Vector2(get_node("body").get_global_pos().x, get_node("body").get_global_pos().y - 10))
			level.add_child(dia)
			dia.ammo(item.ammo)
		
			item.gravitate(myself)
		else:
			current_ammo = ammo_capacity
			
			var dia = Global.Float.duplicate()
			dia.set_global_pos(Vector2(get_node("body").get_global_pos().x, get_node("body").get_global_pos().y - 10))
			level.add_child(dia)
			dia.ammo(item.ammo)
		
			item.gravitate(myself)
	elif item.is_in_group("health"):
		if health == total_health:
			pass
		elif item.health + health > total_health:
			health = total_health
			item.gravitate(myself)
		else:
			health += item.health
			item.gravitate(myself)
		health()
	else:
		if not item in detect_list: 
			detect_list.append(item)
			call_deferred("display")

func display():
	if display != null:
		display.free()
		display = null
	if detect_list != []:
		display = Global.Card.duplicate()
		display.start(detect_list.front())
		h.get_node("Player1").add_child(display)
		display.set_pos(h.get_node("Player1/card_pos").get_pos())

func no_detect(collider):
	if collider.is_in_group("darkness"):
		collider.set_opacity(.5)
	elif detect_list != []:
		if collider in detect_list:
			detect_list.remove(detect_list.find(collider))
			call_deferred("display")

func pick_up(item):
	var grav_dup = item.duplicate()
	if item.get_parent() != null:
		item.get_parent().remove_child(item)
	level.call_deferred("add_child", grav_dup)
	grav_dup.gravitate(myself)
#	pack.append(item)
	item.set_mode(1)
	item.set_layer_mask_bit(10, false)
#	detect_list.remove(detect_list.find(item))
	item.is_equipped = false
	in_pack(item)
	h.get_node("Player1").update_quick_select()
	call_deferred("display")
	pass
	
func in_pack(item):
	if not item.is_in_group("guns and parts"):
		var in_pack = false
		for pack_item in pack:
			if pack_item.name == item.name:
				in_pack = true
				pack_item.amount += 1
		if in_pack == false:
			pack.append(item)
			check_ui_slots(item)

	pass
func check_ui_slots(item):
	var number = 0
	for slot in quick_use:
		if slot == []:
			h.get_node("Player1").place(item, number)
			break
		number += 1

func hud():
	h = hud.duplicate()
	h.get_node("Player1").set_global_pos(Vector2(0 + player_hud_pos, 0))
	h.get_node("Player1").player = self
	add_child(h)
	h.get_node("Player1/Label").set_text(str(name))
	h.get_node("Player1").set_fixed_process(true)
	health()

func hit(collider):
	if hit == false:
		hit = true
		knockback_velocity.x = collider.velocity.x * collider.stopping_power
		knockback_velocity.y = collider.velocity.y * collider.stopping_power

### Rumble
#		Input.start_joy_vibration ( joy, .5, 0, .2 )

#		Input.stop_joy_vibration ( int device )

		var dia = Global.Float.duplicate()
		dia.set_global_pos(Vector2(get_node("body").get_global_pos().x, get_node("body").get_global_pos().y - 10))
		level.add_child(dia)
		dia.damage(collider.damage)
	
		bonus_health -= collider.damage
		if bonus_health < 0:
			health += bonus_health
			bonus_health = 0
			
		poison += collider.poison
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
	health()
	
func red():
	h.get_node("Player1/Sprite").set_modulate(Color(50,0, 0))
	get_node("hit_timer").start()

func use():
	h.get_node("Player1/Sprite").set_modulate(Color(50,25, 0))
	get_node("hit_timer").start()
	var dia = Global.Float.duplicate()
	dia.set_global_pos(Vector2(get_node("body").get_global_pos().x, get_node("body").get_global_pos().y - 10))
	level.add_child(dia)
	dia.use(quick_use[h.get_node("Player1").listx][0].name)
	
func hud_flash_orange():
	h.get_node("Player1/Sprite").set_modulate(Color(50,25, 0))
	get_node("hit_timer").start()

func hud_flash_yellow():
	h.get_node("Player1/Sprite").set_modulate(Color(50,50, 0))
	get_node("hit_timer").start()

func thrown():
	pass

func original_colour():
	h.get_node("Player1/Sprite").set_modulate(Color(1,1, 1))
	hit = false
func death(collider):
	pass
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
	else:
		h.get_node("Player1/health_meter/health").set_scale(Vector2(1, 1))
	if bonus_health > 0:
		h.get_node("Player1/health_meter/bonus_health").set_scale(Vector2((bonus_health/total_health) * scale, 1)) 
	else:
		h.get_node("Player1/health_meter/bonus_health").set_scale(Vector2(1, 1))

func update_hud():
	h.get_node("Player1").Global = get_node("/root/Global")
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
	if not in_building:
		level.get_parent().minimap.get_node("Control/Sprite").set_scale(Vector2(1* flip_mod, 1))

func zone():
	if zone != old_zone:
		if zone.get_parent().get_parent().vector == "x":
			level.get_parent().minimap.get_node("Control/Sprite").set_rotd(90)
			level.get_parent().minimap.get_node("Control/Sprite").set_flip_h(true)
		else:
			level.get_parent().minimap.get_node("Control/Sprite").set_rotd(0)
			level.get_parent().minimap.get_node("Control/Sprite").set_flip_h(false)
		var coords = level.get_parent().minimap.get_node("Control/TileMap").map_to_world(Vector2(zone.get_parent().map_coords[0], zone.get_parent().map_coords[1]))
		level.get_parent().minimap.get_node("Control/Sprite").set_pos(Vector2(coords.x + 10, coords.y + 10))
		old_zone = zone

func slow_walk(backwards):
	if backwards and not walk_slow:
		walk_slow = true
		WALK_SPEED -= WALK_SPEED_TOTAL/3
	elif not backwards and walk_slow:
		walk_slow = false
		WALK_SPEED += WALK_SPEED_TOTAL/3
		
func close():
	if deploying:
		h.get_node("Player1").update_quick_select()
		structure.free()
		construction.free()
		construction = null
		deploying = false
	elif inventory == true:
#		I.get_node("inventory").close()
		I.get_parent().remove_child(I)
		inventory = false
		windows = false
	pass

func melee(type):
	attack_ready = false
	melee = true
	fire_ready.stop()
	if type == "swing":
		m = load("res://Attacks.tscn").instance().get_node("melee/Gun_melee").duplicate()
#		arm_r.set_rotd(arm_r.get_rotd())
#		if arm_r.get_rotd() > 90:
#			arm_r.set_rotd(90)
		melee_attack_time = .25
#		melee_initial_pos = arm_r.get_rotd()
		if primaryGun != []:
			var spawn_point = gun.get_global_pos()
	#		armanim = primaryGun[0].melee_type
			m.player = myself
			m.damage = primaryGun[0].melee[0].melee_swing_damage
			m.stopping_power = primaryGun[0].melee_stopping_power + melee_stopping_power
			m.attacker = self
			m.set_layer_mask(faction.enemynumberval)
			arm_r.add_child(m)
	else:
		m = load("res://Attacks.tscn").instance().get_node("melee/Gun_stab").duplicate()
		melee_attack_time = .25
		if primaryGun != []:
			var spawn_point = gun.get_global_pos()
			get_node("AnimationPlayer").play("stab")
	#		armanim = primaryGun[0].melee_type
			m.player = myself
			m.damage = primaryGun[0].melee[0].melee_stab_damage
			m.stopping_power = primaryGun[0].melee_stopping_power + melee_stopping_power
			m.attacker = self
			m.set_layer_mask(faction.enemynumberval)
			arm_r.add_child(m)
	m = weakref(m)
	fire_ready.set_wait_time(.5)
	fire_ready.start()
	
func use_item(item):
	item.amount -= 1
	h.get_node("Player1").update_quick_select()
	if item.amount <= 0:
		pack.remove(pack.find(item))
		item.free()
		quick_use[h.get_node("Player1").listx] = []
		
func controller(event, p):
	if event.is_action_pressed(p + "grenade") and primaryGun != [] and melee == false: 
			if attack_ready == true and (current_ammo - (ammo_capacity * primaryGun[0].special_ammo_cost)) >= 0:
				special()
		
	if event.is_action_pressed(p + "select_up"):
#		Global.gen.call_deferred("generate_character", self, false)
		if inventory == false and windows == false and grounded:
#			I.get_node("inventory").set_global_pos(Vector2(get_viewport_rect().size.x/ 2, get_viewport_rect().size.y/ 4))
			get_viewport().add_child(I)
			I.get_node("inventory").start()
			windows = true
			inventory = true
#			walk_right = false
#			walk_left = false
#		elif inventory == true:
#			I.get_node("inventory").remove_inventory()
#			I.get_parent().remove_child(I)
#			inventory = false
#			windows = false
	if event.is_action_pressed(p + "select_down"):
		if detect_list != []:
			if detect_list.size() > 1:
				detect_list.append(detect_list.front())
				detect_list.pop_front()
				display()
	elif event.is_action_pressed(p + "m") and not in_building:
		if level.get_parent().minimap.get_node("Control").is_hidden():
			level.get_parent().minimap.get_node("Control").show()
		else:
			level.get_parent().minimap.get_node("Control").hide()

	if event.is_action_pressed(p + "esc"):
		pause.player = self
		level.add_child(pause)
		pause.start()

	if not windows:
		if not deploying:
			if event.is_action_pressed(p + "select_left"):
				if h.get_node("Player1").listx > 0:
					h.get_node("Player1").listx -= 1
				h.get_node("Player1").place_selector()
			elif event.is_action_pressed(p + "select_right"):
				if h.get_node("Player1").listx < quick_use.size() -1:
					h.get_node("Player1").listx += 1
				h.get_node("Player1").place_selector()

		if quick_use[h.get_node("Player1").listx] != []:
			if event.is_action_pressed(p + "place") and not deploying:
				if quick_use[h.get_node("Player1").listx][0].is_in_group("instant"):
					use()
					quick_use[h.get_node("Player1").listx][0].activate(self)
					use_item(quick_use[h.get_node("Player1").listx][0])
				else:
					structure = quick_use[h.get_node("Player1").listx][0].activate()
					construction = Global.traps.get_node("constructor" + str(structure.size)).duplicate()
					faction.add_child(structure)
					construction.structure = structure
					faction.add_child(construction)
					deploying = true
			elif event.is_action_pressed(p + "place") and construction.placeable and deploying and grounded:
				hud_flash_yellow()
				var dia = Global.Float.duplicate()
				dia.set_global_pos(Vector2(get_node("body").get_global_pos().x, get_node("body").get_global_pos().y - 10))
				level.add_child(dia)
				dia.placed(quick_use[h.get_node("Player1").listx][0].name)
				
				deploying = false
				var pos = structure.get_global_pos()
				structure.activate()
				use_item(quick_use[h.get_node("Player1").listx][0])
#				faction.add_child(structure)
				construction.queue_free()
				construction = null

			if event.is_action_pressed(p + "melee") and deploying:
				if not structure.is_in_group("not_flippable"):
					structure.get_node("body").set_scale(Vector2(structure.get_node("body").get_scale().x *-1, 1))

	if event.is_action_pressed(p + "reload") and detect_list != []:
		detect_list.front().equipped()
		pick_up(detect_list.front())
#		if ladder and not ladder_engaged:
#			velocity.y = 0
#			ladder_engaged = true

#	if event.is_action_pressed(p + "equip") and detect_list != []:
#		detect_list.front().equipped()
#		equip(detect_list.front(), true, detect_list.front().slot)

	if event.is_action_pressed(p + "L1") and primaryGun != []:
		if reloading == false and primaryGun[0].current_clip < primaryGun[0].clip_capacity and current_ammo > 0:
			reload()
	elif event.is_action_pressed(p + "switch") and (primaryGun != [] or secondaryGun != []):
		swap()

	if event.is_action_pressed(p + "crouch") and not deploying:
		if is_prone == false:
			crouching = true
#			arm_r.set_rot(get_node("body").get_angle_to(get_global_mouse_pos()) - 3.14159/2)
			get_node("move").play("prone_idle")
			is_prone = true
			get_node("prone").set_trigger(false)
			get_node("standing").set_trigger(true)
		elif not get_node("crouch").is_colliding():
			standing = true
			is_prone = false
			get_node("move").play("idle")
			get_node("prone").set_trigger(true)
			get_node("standing").set_trigger(false)
			
	elif event.is_action_pressed(p + "crouch"):
		if deploying:
			h.get_node("Player1").update_quick_select()
			structure.queue_free()
			construction.queue_free()
			construction = null
			deploying = false
#		elif place == true:
#			Build.queue_free()
#			selected.queue_free()
#			place = false
#			windows = false

	elif event.is_action_pressed(p + "jump"):
		if is_prone == true:
			if not get_node("crouch").is_colliding():
				standing = true
				is_prone = false
				get_node("move").play("idle")
				get_node("prone").set_trigger(true)
				get_node("standing").set_trigger(false)

		elif jump_l.is_colliding() or jump_r.is_colliding():
			jumping = true
			jump_animate = true
			get_node("move").play("jump_up")
			velocity.y = -JUMP_FORCE/2
			jump_press = 0
	elif event.is_action_released(p + "jump"):
		jumping = false
		
	if Input.get_joy_axis(joy, JOY_ANALOG_0_X) > .5 and not walk_right and windows == false:
		walk_right = true
	elif (Input.get_joy_axis(joy, JOY_ANALOG_0_X) < .5 and walk_right) or windows == true:
		walk_right = false
	if Input.get_joy_axis(joy, JOY_ANALOG_0_X) < -.5 and not walk_left and windows == false:
		walk_left = true
	elif (Input.get_joy_axis(joy, JOY_ANALOG_0_X) > -.5 and walk_left) or windows == true:
		walk_left = false
	
#	if event.is_action_pressed(p + "melee") and not melee_ready and attack_ready:
#		melee_ready = true
#	elif event.is_action_released(p + "melee") and melee_ready and attack_ready:
#		melee_ready = false
#		melee_attack = true

	if  event.is_action_pressed(p + "fire") and primaryGun != []:
		fire = true
	elif event.is_action_released(p + "fire") or (fire and  (primaryGun == [] or windows)):
		fire = false
	if  event.is_action_pressed(p + "ui_ctrl") and windows == false:
		aiming = true
	elif event.is_action_released(p + "ui_ctrl") or (aiming and (windows or melee)) or primaryGun == []:
		aiming = false
	
func _input(event):
	controller(event, pl)

func _fixed_process(delta):
	for dark in get_node("Area2D1").get_overlapping_bodies():
		dark.set_opacity(.5)
	for dark in get_node("Area2D").get_overlapping_bodies():
		if dark.is_in_group("darkness"):
			dark.call_deferred("set_opacity", 0)
	reloading(delta)
	remove_comment(delta)
	gravity_check(delta)
	grounded_check()
	if windows == false:
		if melee_ready:
			melee_time -= delta
		if not melee_ready and melee_attack or melee_time <= 0:
			melee_ready = false
			melee_attack = false
			if melee_time <= 0:
				melee_time = .3
				melee("swing")
				melee_swing = true
			else:
				melee("stab")
				melee_time = .3
				melee_stab = true
		elif melee_swing:
			melee_attack_time -= delta
			if melee_attack_time > 0:
				arm_r.rotate(-.1)
			else:
				melee_swing = false
		elif melee_stab:
			melee_attack_time -= delta
			if melee_attack_time < 0:
				melee_stab = false
		

		
		if fire:
			if attack_ready == true and primaryGun[0].current_clip > 0 and not reloading:
#				h.get_node("Player1").volume(primaryGun[0].volume)
				fire()
			elif reloading == false and primaryGun[0].current_clip <= 0 and current_ammo > 0:
				reload()
				
				
		if controller:
			var direction = Vector2(Input.get_joy_axis(joy, JOY_ANALOG_1_X) + get_node("body").get_global_pos().x, Input.get_joy_axis(joy, JOY_ANALOG_1_Y) + get_node("body").get_global_pos().y)
			var angle = get_node("body").get_angle_to(direction)
			if abs(Input.get_joy_axis(joy, JOY_ANALOG_1_X)) > .7 or abs(Input.get_joy_axis(joy, JOY_ANALOG_1_Y)) > .7:
				get_node("body/can_shoot").set_rotd(rad2deg(angle) - 90)
	#		get_node("can_shoot").look_at(get_global_mouse_pos())
	#		print(get_node("can_shoot").get_rotd())
	
#			arm_r.get_node("can_shoot").force_raycast_update()
#			arm_r.get_node("shoot_collider_bottom").force_raycast_update()
#			get_node("body/can_shoot").force_raycast_update()

#			if  arm_r.get_node("shoot_collider_bottom").is_colliding() and not arm_r.get_node("can_shoot").is_colliding() and get_node("body/can_shoot").is_colliding():
#				pass
#			if arm_r.get_rotd() <= get_node("body/can_shoot").get_rotd() + 5 and arm_r.get_rotd() >= get_node("body/can_shoot").get_rotd() -5 and not arm_r.get_node("can_shoot").is_colliding():
#				pass 
#			if (arm_r.get_node("shoot_collider_bottom").is_colliding() or arm_r.get_node("shoot_collider_top").is_colliding()) and melee:
#				melee = false
#				melee_swing = false
#				melee_stab = false
#				if !m.get_ref():
#					m = null
#				else:
#					m.get_ref().queue_free()
			
#			elif get_node("body/can_shoot").is_colliding() and (not arm_r.get_node("shoot_collider_top").is_colliding() and not arm_r.get_node("shoot_collider_bottom").is_colliding()):
#				arm_r.rotate(sign(get_node("body/can_shoot").get_rotd()) * .1)
			arm_r.set_rotd(get_node("body/can_shoot").get_rotd())
			
#			if arm_r.get_node("can_shoot").is_colliding() and abs(arm_r.get_rotd()) > 3:
#				arm_r.rotate(sign(arm_r.get_rotd()) * - .1)
#			elif (arm_r.get_rotd() < get_node("body/can_shoot").get_rotd() - 1 or arm_r.get_rotd() > get_node("body/can_shoot").get_rotd() + 1):
#				if get_node("body/can_shoot").is_colliding() and not arm_r.get_node("shoot_collider_bottom").is_colliding(): 
#					arm_r.rotate(sign(get_node("body/can_shoot").get_rotd()) * .1)
#	
#				elif not arm_r.get_node("can_shoot").is_colliding():
#					arm_r.set_rotd(get_node("body/can_shoot").get_rotd())
#				else:
#					print(arm_r.get_node("can_shoot").get_collider())
					

#			elif get_node("body/can_shoot").is_colliding() and (arm_r.get_rotd() < get_node("body/can_shoot").get_rotd() - 20 or arm_r.get_rotd() > get_node("body/can_shoot").get_rotd() + 20):
#				arm_r.set_rotd(round(get_node("body/can_shoot").get_rotd()))
			
#			elif not arm_r.get_node("shoot_collider_bottom").is_colliding():
#				arm_r.set_rotd(get_node("body/can_shoot").get_rotd())
			if abs(get_node("body/can_shoot").get_rotd()) > 90 and not melee:
				if flipped == false:
					flip(true)
					flipped = true
					arm_r.set_rot(-arm_r.get_rot())
	#				head.set_rot(-head.get_rot())
				elif flipped == true:
					flip(false)
					flipped = false
					arm_r.set_rot(-arm_r.get_rot())
	#				head.set_rot(-head.get_rot())
				get_node("body/can_shoot").set_rotd(0)
			if not melee_swing:
				if abs(get_node("body/can_shoot").get_rotd()) < 50:
					head.set_rotd(get_node("body/can_shoot").get_rotd())
				elif abs(get_node("body/can_shoot").get_rotd()) > 50:
					head.set_rotd( 50 * sign(get_node("body/can_shoot").get_rotd()))
			if not left_arm_in_use:
				arm_l.set_rotd(arm_r.get_rotd())
				
				
		else:
			get_node("body/can_shoot").set_pos(arm_r.get_pos())
	#		Vector2(arm_r.get_global_pos().x, arm_r.get_global_pos().y - 4))
			get_node("body/can_shoot").set_rot(get_node("body").get_angle_to(get_global_mouse_pos()) - 3.14159/2)
	#		get_node("can_shoot").look_at(get_global_mouse_pos())
	#		print(get_node("can_shoot").get_rotd())
	#		if (arm_r.get_node("shoot_collider_top").is_colliding() or arm_r.get_node("shoot_collider_bottom").is_colliding()) and not arm_r.get_node("can_shoot").is_colliding():
	#			pass
			if (arm_r.get_node("shoot_collider_bottom").is_colliding() or arm_r.get_node("shoot_collider_top").is_colliding()) and melee:
				melee = false
				melee_swing = false
				melee_stab = false
				if !m.get_ref():
					m = null
				else:
					m.get_ref().queue_free()
			
			if get_node("body/can_shoot").is_colliding() and (not arm_r.get_node("shoot_collider_top").is_colliding() and not arm_r.get_node("shoot_collider_bottom").is_colliding()):
	#			if abs(arm_r.get_rotd()) < abs(get_node("can_shoot").get_rotd()):
				arm_r.rotate(sign(get_node("body/can_shoot").get_rotd()) * .1)
	#			arm_r.get_node("shoot_collider_top").force_raycast_update()
	#			arm_r.get_node("shoot_collider_bottom").force_raycast_update()
	#arm_r.set_rotd(arm_r.get_rotd()
#			elif arm_r.get_node("can_shoot").is_colliding() and not melee and not abs(arm_r.get_rotd()) < 1:
	#			if abs(arm_r.get_rotd()) < abs(get_node("can_shoot").get_rotd()):
#				arm_r.rotate(sign(arm_r.get_rotd()) * - .1)
	#			arm_r.get_node("can_shoot").force_raycast_update()
			elif ((not melee and not get_node("body/can_shoot").is_colliding()) and ( not melee_stab and not melee_swing)) or (not get_node("body/can_shoot").is_colliding() and ((arm_r.get_angle_to(get_global_mouse_pos()) - 3.14159/2 > arm_r.get_rot() and arm_r.get_node("shoot_collider_bottom").is_colliding()) or (arm_r.get_angle_to(get_global_mouse_pos()) - 3.14159/2 < arm_r.get_rot() and arm_r.get_node("shoot_collider_top").is_colliding()))):
				if controller:
					var direction = Vector2(Input.get_joy_axis(0, JOY_ANALOG_1_X), Input.get_joy_axis(0, JOY_ANALOG_1_Y))
					var angle = direction.angle()
					arm_r.set_rotd(rad2deg(angle) - 90)
				else:
					arm_r.set_rot(get_node("body").get_angle_to(get_global_mouse_pos()) - 3.14159/2)
			if abs(get_node("body/can_shoot").get_rotd()) > 90 and not melee:
				if flipped == false:
					flip(true)
					flipped = true
					arm_r.set_rot(-arm_r.get_rot())
					head.set_rot(-head.get_rot())
				elif flipped == true:
					flip(false)
					flipped = false
					arm_r.set_rot(-arm_r.get_rot())
					head.set_rot(-head.get_rot())
			if not melee_swing:
				if abs(get_node("body/can_shoot").get_rotd()) < 50:
					head.set_rot(get_node("body").get_angle_to(get_global_mouse_pos()) - 3.14159/2)
				elif abs(get_node("body/can_shoot").get_rotd()) > 50:
					head.set_rotd( 50 * sign(get_node("body/can_shoot").get_rotd()))
			if not left_arm_in_use:
				arm_l.set_rotd(arm_r.get_rotd())
	
	

	if aiming and primaryGun != [] and grounded:
		primaryGun[0].aiming(true, faction.enemynumberval)
		if not aim:
			WALK_SPEED -= 50
		aim = true
	elif aim == true:
		WALK_SPEED += 50
		aim = false
		if primaryGun != []:
			primaryGun[0].aiming(false, faction.enemynumberval)
		
	if (jump_press < 0.15) and jumping == true:
		jump_press += delta
		velocity.y -= JUMP_FORCE * 2 * delta
		if jump_press >= 0.15:
			jumping = false
			
	if walk_left:
		if not grounded:
			if not is_colliding():
				if velocity.x > -WALK_SPEED:
					velocity.x -= ACCELERATION * acceleration_modifier
		elif not is_prone:
			if velocity.x > 0:
				velocity.x = 0
			if velocity.x > -WALK_SPEED:
				velocity.x -= ACCELERATION
			else:
				velocity.x = -WALK_SPEED
		elif is_prone:
			if velocity.x > 0:
				velocity.x = 0
			if velocity.x > -WALK_SPEED/2:
				velocity.x -= ACCELERATION
			else:
				velocity.x = -WALK_SPEED/2

	elif walk_right:
		if not grounded:
			if not is_colliding():
				if velocity.x < WALK_SPEED:
					velocity.x += ACCELERATION * acceleration_modifier
		elif not is_prone:
			if velocity.x < 0:
				velocity.x = 0
			if velocity.x < WALK_SPEED:
				velocity.x += ACCELERATION
			else:
				velocity.x = WALK_SPEED
		elif is_prone:
			if velocity.x < 0:
				velocity.x = 0
			if velocity.x < WALK_SPEED/2:
				velocity.x += ACCELERATION
			else:
				velocity.x = WALK_SPEED/2
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
	if (walk_right and flipped) or (walk_left and not flipped):
		slow_walk(true)
	else:
		slow_walk(false)
	
	if crouching or standing:
		crouching = false 
		standing = false
	else:
		if grounded and not jumping:
			get_node("move").set_speed(WALK_SPEED/ WALK_SPEED_TOTAL)
	#		if not is_prone and get_node("crouch").is_colliding():
	#			prone(true)
			if (walk_right or walk_left) and not is_prone:
				if not get_node("move").is_playing():
					if (walk_right and flipped) or (walk_left and not flipped):
						slow_walk(true)
						get_node("move").play_backwards("run")
					else:
						get_node("move").play("run")
						
			elif not is_prone:
				get_node("move").play("idle")
			
			if (walk_right or walk_left) and grounded and is_prone:
				if not get_node("move").is_playing():
					get_node("move").play("prone_crawl")
			elif is_prone:
				get_node("move").play("prone_idle")
		elif not grounded and not jumping and velocity.y > 0 and jump_animate and not is_prone:
			get_node("move").play("jump_down")
			jump_animate = false


	if deploying:
		var follow_pos
#		if not flipped:
		follow_pos = Vector2(get_global_pos().x + (25 * structure.size * flip_mod), get_global_pos().y)
#		else:
#			follow_pos = Vector2(get_global_pos().x + (20 * flip_mod), get_global_pos().y)
		var coords = level.get_node("TileMap").world_to_map(follow_pos)
		var revert = level.get_node("TileMap").map_to_world(coords)
		var tilesize = level.get_node("TileMap").get_cell_size()
		construction.set_global_pos(revert + Vector2(tilesize.x / 2, tilesize.y - 6))
		structure.set_global_pos(revert + Vector2(tilesize.x / 2, tilesize.y - 6))
	the_movement(delta)
	knockback()
	if effect != null:
		effect(delta)