extends "res://Data/Basic_infantry.gd"
var I = preload("res://Inventory_hud.tscn").instance()
var h = preload("res://HUD.tscn").instance()
var c = preload("res://Commands.tscn").instance()
var g = preload("res://Explosives.tscn").instance()
var basic_gun
var Guns = preload("res://Guns.tscn")
var name = "Shannon"

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

func _ready():
	total_health = 100.0
	set_fixed_process(true)
	set_process_input(true)
	level = get_parent().get_parent()
	faction = get_parent()
	get_node("body").set_layer_mask_bit(get_parent().sidenumber, true)
	get_node("body").add_to_group(faction.side)
	faction.player_list.append(self)
	arm_r = get_node("body/arm_r")
	head = get_node("body/Head")
	jump_l = get_node("jump_l")
	jump_r = get_node("jump_r")
	comment_box = get_node("comment_box")
	comment = get_node("comment_box/comment")
	animNode = get_node("body/legs")
	armanimNode = get_node("AnimationPlayer")
	head = get_node("body/Head")
	arm_r= get_node("body/arm_r")
	fire_ready = get_node("fire_ready")
	fire_ready.connect("timeout", self, "fireready")
	get_node("hit_timer").connect("timeout", self, "original_colour")
	faction.player_list.append(self)
	health = total_health
	orders = c.get_node("Commands")
	call_deferred("hud", h)

	basic_gun = Guns.instance().get_node("Tier_1/M14").duplicate()
	basic_gun.generate("Tier_1")
	if primaryGun == []:
		equip(basic_gun, false, "primaryGun")
		basic_gun.start()

func display(button, description):
	if button == null:
		get_node("Label").set_text(" ")
	else:
		get_node("Label").set_text(str(button) + " " + description)
		
func hud(add):
	h.get_node("Player1").set_global_pos(Vector2(get_viewport().get_rect().size.x - get_viewport().get_rect().size.x + 50, get_viewport().get_rect().size.y - 75))
	add_child(h)
	player_health()
	update_hud()

func hit(collider):
	if hit == false:
		red()
		knockback_velocity.x = collider.velocity.x * collider.stopping_power
		knockback_velocity.y = collider.velocity.y * collider.stopping_power
	#	if dead == false:
		health -= collider.damage
		player_health()
		hit = true
		get_node("hit_timer").start()
		

func original_colour():
	hit = false
	arm_r.set_modulate(Color(1, 1, 1))
	head.set_modulate(Color(1, 1, 1))
	get_node("body/legs").set_modulate(Color(1, 1, 1))
	
func red():
	arm_r.set_modulate(Color(255,0, 0))
	head.set_modulate(Color(255,0, 0))
	get_node("body/legs").set_modulate(Color(255,0, 0))
	
func player_health():
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
	if primaryGun != []:
		total_ammo = primaryGun[0].ammo_capacity
		current_ammo = primaryGun[0].current_ammo
		bullet_list = primaryGun[0].bullet_list
	else:
		total_ammo = 0
		current_ammo = 0
		bullet_list = []
	h.get_node("Player1").update_hud()
		
func command(command):
	standingorders = command
	for ally in faction.attacker_list:
		ally.orders(command)
	
func recruit(object):
	faction.points -= object.cost
	update_hud()
	windows = false
	object.set_pos(level.get_node("player_1_spawn").get_pos())
	faction.add_child(object)
	
#	if object.is_in_group("engineers"):
#		get_parent().ally_engineer_list.append(object)
#	else:
#		get_parent().ally_list.append(object)
	object.hold_order("add")

func building(object, build):
	selected = object
	Build = build
	build.structure = selected
	faction.add_child(selected)
	faction.add_child(Build)
	place = true

func deploy(object, build):
	selected = object
	Build = build
	var mouse_pos = get_global_mouse_pos()
	var coords = level.get_node("TileMap").world_to_map(get_global_mouse_pos())
	var revert = level.get_node("TileMap").map_to_world(coords)
	level.add_child(Build)
	level.add_child(selected)
	selected.set_global_pos(coords)
	Build.set_global_pos(coords)
	place = true
	
func flip(flipped):
	if flipped:
		flip_mod = -1
	else:
		flip_mod = 1
	get_node("body").set_scale(Vector2(1 * flip_mod, 1))
	head.set_rotd(head.get_rotd() * -1)
	arm_r.set_rotd(arm_r.get_rotd() * -1)
	
func prone(proned):
	if proned:
		get_node("body").set_pos(Vector2(0, 14))
		get_node("body/prone").set_trigger(false)
		get_node("body/standing").set_trigger(true)
#		get_node("body/prone").set_pos(get_node("body/legs").get_pos())
	else:
		get_node("body").set_pos(Vector2(0, 0))
		get_node("body/standing").set_trigger(false)
		get_node("body/prone").set_trigger(true)
#		get_node("body/standing").set_pos(get_node("body/legs").get_pos())
		
	if is_prone != true:
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

	elif is_prone == true:
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
	get_node("body/headcollision").set_pos(head.get_pos())
	flip(flipped)
	
		
func _input(event):
	if event.is_action_pressed("grenade"):
		var grenade = g.get_node("grenade").duplicate()
		var Aimrot = arm_r.get_rot()
		var pos = Vector2(cos(Aimrot), -sin(Aimrot))
		var spawn_point = pos + head.get_global_pos()
		spawn_point.y - 10
#		grenade.set_rot(Aimrot)
		grenade.throwx = max(min(abs(45 + rad2deg(Aimrot)) * 5, 200), 100)
		grenade.throwy =  max(min(abs(45 + rad2deg(Aimrot)) * -6, -350), -500)
		print(grenade.throwy)
#		if grenade.throwy > 0:
#			grenade.throwy *= -1
#		if grenade.throwx > 0 and flip_mod == -1:
#			grenade.throwx *= -1
		grenade.set_pos(spawn_point) 
		grenade.flip_mod = flip_mod
		level.add_child(grenade)
		grenade.activate(side)

	
	if event.is_action_pressed("inventory"):
		if inventory == false  and windows == false:
			I.get_node("inventory").set_global_pos(Vector2(get_viewport_rect().size.x/ 2, get_viewport_rect().size.y/ 4))
			get_viewport().add_child(I)
			I.get_node("inventory").show_inventory(self)
			windows = true
			inventory = true

		
	elif event.is_action_pressed("command"):
		if command == false and windows == false:
			command = true
			orders.set_pos(Vector2(0, -100))
			if orders.get_parent() != null:
				orders.get_parent().remove_child(orders)
			orders.player = self
			add_child(orders)
			windows = true
		elif command == true:
			command = false
			orders.get_parent().remove_child(orders)
			windows = false
		elif place == true:
			selected.queue_free()
			Build.queue_free()
			place = false
			windows = false
		elif inventory == true:
			I.get_node("inventory").remove_inventory(self)
			I.get_parent().remove_child(I)
			inventory = false
			windows = false
		
	elif event.is_action_pressed("place") and place == true:
		if Build.placeable:
			windows = false
			faction.points -= selected.cost
#			selected.get_parent().remove_child(selected)
#			faction.add_child(selected)
			Build.activate()
			update_hud()
			place = false
		
	if event.is_action_pressed("reload") and primaryGun != []:
		if reloading == false and primaryGun[0].current_clip < primaryGun[0].clip_capacity:
			reload()
#		h.get_node("Player1").clear_ammo()
#		h.get_node("Player1").ammo(self)
	elif event.is_action_pressed("switch") and (primaryGun != [] or secondaryGun != []):
		swap()
		
	elif event.is_action_pressed("fire") and primaryGun != [] and melee == false: 
		if attack_ready == true and primaryGun[0].current_ammo > 0 and primaryGun[0].current_clip > 0 and primaryGun[0].fullauto == false:
			fire()
#			h.get_node("Player1").shoot(self)
		elif attack_ready == true and primaryGun[0].current_clip <= 0 and primaryGun[0].current_ammo > 0:
			reload()
	elif event.is_action_pressed("melee") and melee == false:
		melee()
		
	if event.is_action_pressed("ui_down"):
		if is_prone == false:
			is_prone = true
			prone(true)
			flip(flipped)
			anim = "prone_idle"

	elif event.is_action_pressed("ui_up"):
		if is_prone == true:
			is_prone = false
			prone(false)
			flip(flipped)
		elif grounded:
			jumping = true
			velocity.y = -JUMP_FORCE/2
			jump_press = 0
	elif event.is_action_released("ui_up"):
		jumping = false
		

func _fixed_process(delta):
	remove_comment(delta)
	gravity_check(delta)
	grounded_check()
	if Input.is_action_pressed("fire") and primaryGun != [] and melee == false: 
		if attack_ready == true and primaryGun[0].fullauto == true and primaryGun[0].current_clip > 0:
			fire()
			
	if Input.is_action_pressed("ui_lookup") and head.get_rotd() <= 45:
		arm_r.rotate(AIMSPEED)
	elif Input.is_action_pressed("ui_lookdown") and head.get_rotd() > -45:
		arm_r.rotate(-AIMSPEED)
	if not melee:
		head.set_rot(arm_r.get_rot())
		
	if Input.is_action_pressed("ui_ctrl"):
		WALK_SPEED = 100
		PRONE_SPEED = 50
		primaryGun[0].aiming(true, 4)
		aim = true
		AIMSPEED = .01
	elif aim == true:
		WALK_SPEED = 200 
		PRONE_SPEED = 50
		AIMSPEED = .05
		aim = false
		primaryGun[0].aiming(false, 1)


	if place == true:
		var mouse_pos = get_global_mouse_pos()
		var coords = level.get_node("TileMap").world_to_map(get_global_mouse_pos())
		var revert = level.get_node("TileMap").map_to_world(coords)
		var tilesize = level.get_node("TileMap").get_cell_size()
		Build.set_pos(revert + Vector2(tilesize.x / 2, tilesize.y))
		Build.set_rot(0)
		selected.set_pos(revert + Vector2(tilesize.x / 2, tilesize.y))
		selected.set_rot(0)
		
	if (jump_press < 0.25) and jumping == true:
		jump_press += delta
		velocity.y -= JUMP_FORCE * 2 * delta

	if Input.is_action_pressed("ui_left"):
		if flipped == false:
			flip(true)
			flipped = true
			arm_r.set_rot(-arm_r.get_rot())
			head.set_rot(-head.get_rot())
		if not grounded:
			if velocity.x > -WALK_SPEED:
				velocity.x -= ACCELERATION * acceleration_modifier
			if is_prone:
				anim = "prone_idle"
			else:
				anim = "jump"
		elif not is_prone:
			anim = "run"
			if velocity.x > -WALK_SPEED:
				velocity.x -= ACCELERATION
			else:
				velocity.x += DECCELERATION
		elif is_prone:
			anim = "prone_crawl"
			if velocity.x > -PRONE_SPEED:
				velocity.x -= ACCELERATION
			else:
				velocity.x += DECCELERATION / 2

	elif Input.is_action_pressed("ui_right"):
		if flipped:
			flip(false)
			flipped = false
			arm_r.set_rot(-arm_r.get_rot())
			head.set_rot(-head.get_rot())
		if not grounded:
			if velocity.x < WALK_SPEED:
				velocity.x += ACCELERATION * acceleration_modifier
			if is_prone:
				anim = "prone_idle"
			else:
				anim = "jump"
		elif not is_prone:
			anim = "run"
			if velocity.x < WALK_SPEED:
				velocity.x += ACCELERATION
			else:
				velocity.x -= DECCELERATION
		elif is_prone:
			anim = "prone_crawl"
			if velocity.x < PRONE_SPEED:
				velocity.x += ACCELERATION
			else:
				velocity.x -= DECCELERATION / 2
	else:
		if velocity.y < 0 and not grounded:
			if not is_prone:
				anim = "jump"
		elif velocity.y >= 0 and not grounded:
			if not is_prone:
				anim = "idle"
		elif not is_prone:
			anim = "idle"
		else:
			anim = "prone_idle"
		if abs(velocity.x) < 5:
			velocity.x = 0
		elif abs(velocity.x) > 0:
			if not grounded:
				velocity.x -=  2 * sign(velocity.x)
			elif is_prone:
				velocity.x -=  DECCELERATION / 2 * sign(velocity.x)
			else:
				velocity.x -= DECCELERATION * sign(velocity.x)
	the_movement(delta)
	knockback()
	animation()