extends RigidBody2D
var name = "M14"
var named = "M14"
var value = 10

var slot = "primaryGun"
var weight = 5
var damage = 1
var bulletspeed = 300
var stopping_power = 1
var fire_rate = 0.3
var clip_capacity = 20
var current_clip = 120
var ammo_capacity = 400
var current_ammo = 400
var reload_speed = 2
var distance = 1
var accuracy = 2
var fullauto = true
var bullets_inbullets = 1

var shrapnel = 0
var explode_damage = 0

var melee_damage = 0
var melee_stopping_power = 0
#var melee_speed = .5
var melee_type = ''

var special_damage = 0
var special_stopping_power = 0
#var melee_speed = .5
var special_ammo_cost = 0
var special_fire_rate = 1
#var melee_type = ''

var bullettype
var b = preload("res://Attacks.tscn")
var gp = preload("res://Gun_parts.tscn")

var countdown = 10
var GRAVITY = 100
var velocity
var random
var flipped = false
var locked = true
var barrel = []
var melee = []
var clip = []
var mod = []
var special = []

var pickup_area
var pickup = false
var player
var aiming = false
var is_equipped = false
var stats
var type = ""
var Global
func _ready():
	Global = get_node("/root/Global")
	var damaged = "Dam: " + str(damage)
	var fire_rated = "Rof: " + str(round(fire_rate/3 * 100))
	var accuracyd = "Acc: " + str(round(accuracy/5 * 100 - 100) *-1)
	var distanced = "Ran: " + str(round(distance/3 * 100))
	var stopping_powerd = "KB: " + str(round(stopping_power/10 * 100))
	var ammo_capacityd = "Ammo: " + str(round(ammo_capacity))
	var clip_capacityd = "Mag: " + str(round(clip_capacity))
	stats = [stopping_powerd, fire_rated, accuracyd, distanced, ammo_capacityd, clip_capacityd]
	stats.sort()
	stats.push_front(damaged)
	set_fixed_process(true)
#	locked = true

func start():
	current_clip = int(rand_range(1, clip_capacity))
#	ammo()

func bullettype():
	var new_bullet = b.instance().get_node(type + "/basic").duplicate()
	new_bullet = clip[0].bullet(new_bullet)
#	mod[0].bullet(new_bullet)
	new_bullet = barrel[0].bullet(new_bullet)
	new_bullet = mod[0].bullet(new_bullet)
	new_bullet.distance = distance
	new_bullet.stopping_power = stopping_power
	new_bullet.damage = float(damage) / float(bullets_inbullets)
	new_bullet.bulletspeed = bulletspeed
	return new_bullet


func ammo():
	pass
#	for bullet in range(current_clip):
#		bullet_list.append([])
#	for lists in bullet_list:
#		for number in range(bullets_inbullets):
#			var new_bullet = bullettype.duplicate()
	
#			lists.append(new_bullet)
#	get_parent().bullet_list = bullet_list
func reload():
	if (current_ammo + current_clip) < clip_capacity:
		current_clip = current_ammo
		print(str(current_ammo))
		current_ammo = 0
	elif current_clip > 0:
		current_ammo -= (clip_capacity - current_clip)
		current_clip = clip_capacity
	else:
		current_ammo -= clip_capacity
		current_clip = clip_capacity
#	ammo()
func unequip(part, location):
#	damage -= part.damage
#	clip_capacity -= part.clip_capacity
#	reload_speed -= part.reload_speed
#	fire_rate -= part.fire_rate
#	accuracy -= part.accuracy
#	distance -= part.distance
#	stopping_power -= part.stopping_power
#	if part.fullauto != null:
#		!fullauto
	if location == "barrel":
		get_node("body/barrel_tip").set_pos(Vector2(get_node("body/barrel_tip").get_pos().x - part.barrel_size, get_node("body/barrel_tip").get_pos().y))
		barrel.pop_back()
	elif location == "clip":
		clip.pop_back()
	elif location == "mod":
		mod.pop_back()
	elif location == "special":
		special.pop_back()
	elif location == "melee":
		melee_damage -= part.melee_damage
		melee_type = ''
		melee_stopping_power -= part.melee_stopping_power
		melee.pop_front()
		
func equip_display(part, location):
	part.get_parent().remove_child(part)
	add_child(part)
	part.set_global_pos(get_node("body/" + location).get_global_pos())
	
#func _input(event):
#	if event.is_action_pressed("equip") and pickup == true:
#		lock()
#		self.get_parent().remove_child(self)
#		player.equip(self, true, slot)
#	elif event.is_action_pressed("pickup") and pickup == true:
#		lock()
#		self.get_parent().remove_child(self)
#		player.pack.append(self)

func equipped():
	set_mode(1)
	set_layer_mask_bit(10, false)
	is_equipped = true

func drop():
	var flip
	var level = Global.player.level
	if get_parent() != null:
		flip = get_parent().get_parent().get_parent().flip_mod
		if self in get_parent().get_parent().get_parent().primaryGun:
			get_parent().get_parent().get_parent().unequip_change("primaryGun")
		elif self in get_parent().get_parent().get_parent().secondaryGun:
			get_parent().get_parent().get_parent().unequip_change("secondaryGun")
		var rot = get_rotd()
		var pos = get_global_pos()
		self.get_parent().remove_child(self)
		set_global_pos(pos)
		set_rotd(rot)
		set_scale(Vector2(1 * flip, 1))

	else:
		flip = Global.player.flip_mod
		set_global_pos(Vector2(Global.player.get_global_pos().x, Global.player.get_global_pos().y - 20))
		set_rotd(0)
		set_scale(Vector2(1 * flip, 1))
		if Global.on_supply_run:
			Global.supply_run_pack.remove(Global.supply_run_pack.find(self))
		else:
			Global.pack.remove(Global.pack.find(self))
	level.add_child(self)
	set_mode(0)
	set_layer_mask_bit(10, true)
	apply_impulse(Vector2(), Vector2(0, 5))

	is_equipped = false
	
func equip(part, location):
#	damage += part.damage
#	clip_capacity += part.clip_capacity
#	reload_speed += part.reload_speed
#	fire_rate += part.fire_rate
#	accuracy += part.accuracy
#	distance += part.distance
#	stopping_power += part.stopping_power
#	if part.fullauto != null:
#		fullauto = part.fullauto
	part.get_parent().remove_child(part)
	get_node("body").add_child(part)
	part.set_pos(get_node("body/" + location).get_pos())
	if location == "barrel":
		get_node("body/barrel_tip").set_pos(Vector2(get_node("body/barrel_tip").get_pos().x + part.barrel_size, get_node("body/barrel_tip").get_pos().y))
		part.equip(self)
		barrel.push_front(part)
	elif location == "clip":
		clip.push_front(part)
	elif location == "mod":
		mod.push_front(part)
	elif location == "special":
		special_damage = part.special_damage
		special_stopping_power = part.special_stopping_power
		special_ammo_cost = part.special_ammo_cost
		special.push_front(part)
	elif location == "melee":
		melee_damage += part.melee_damage
		melee_type = part.melee_type
		melee_stopping_power += part.melee_stopping_power
		melee.push_front(part)

		
func generate(tier):
	var b = gp.instance().get_node(tier).random("barrel")
	var m = gp.instance().get_node(tier).random("melee")
	var c = gp.instance().get_node(tier).random("clip")
	var sp = gp.instance().get_node(tier).random("special")
	var sm = gp.instance().get_node(tier).random("mod")
	equip(b, "barrel")
	equip(m, "melee")
	equip(c, "clip")
	equip(sp, "special")
	equip(sm, "mod")
	
func shoot():
	get_node("AnimationPlayer").play("Shoot")
	get_node("SamplePlayer2D").play("shoot")
	current_clip -= 1

func special_shoot():
	get_node("AnimationPlayer").play("Shoot")
	current_ammo -= (ammo_capacity * special_ammo_cost)

func unlock():
	locked = false
	aiming = false
	set_fixed_process(true)
	set_process_input(true)
	random = rand_range(-.05, .05)
	pickup = false
	pickup_area = get_node("Pickup")
	pickup_area.show()
	countdown = 10
	get_node("CollisionShape2D").set_trigger(false)
	pickup_area.connect("body_enter", self, "pickmeup")
	pickup_area.connect("body_exit", self, "cantpickmeup")
	
func lock():
	locked = true
#	set_fixed_process(false)
	set_process_input(false)
	get_node("CollisionShape2D").set_trigger(true)
	get_node("Pickup").hide()
	pickup_area.disconnect("body_enter", self, "pickmeup")
	pickup_area.disconnect("body_exit", self, "cantpickmeup")
	pickup = false
#	print('we locked')

func pickmeup(collider):
	if collider.is_in_group("players"):
		pickup = true
		get_node("Pickup/pick me up!").show()
		player = collider
		
func cantpickmeup(collider):
	if collider.get_name() != "TileMap" or collider.get_name() != "TileMap 2":
		pickup = false
		get_node("Pickup/pick me up!").hide()

func aiming(choice, number):
	get_node("body/RayCast2D").set_layer_mask(number) 
	get_node("body/RayCast2D").set_enabled(choice)
	set_fixed_process(true)
	aiming = choice
	
func _fixed_process(delta):
	if aiming:
		get_node("body/RayCast2D").set_cast_to(Vector2(bulletspeed * distance, 0))
		if get_node("body/RayCast2D").is_colliding():
			get_node("body/RayCast2D/lazer_sight").set_scale(Vector2(get_node("body/RayCast2D/lazer_sight").get_global_pos().distance_to(get_node("body/RayCast2D").get_collision_point()), 1))
		else:
			get_node("body/RayCast2D/lazer_sight").set_scale(Vector2(get_node("body/RayCast2D").get_cast_to().x, 1))
	else:
		get_node("body/RayCast2D/lazer_sight").set_scale(Vector2(0, 1))
	if not locked:
		velocity = Vector2()
		velocity.y += delta * GRAVITY
		countdown -= delta
		if countdown <= 0:
			queue_free()
		if is_colliding():
			set_fixed_process(false)
		else:
			random = rand_range(-.05, .05)
			rotate(random)
		move(velocity)
	if not aiming and locked:
		set_fixed_process(false)
		
func flip(flipped):
	var flip_mod
	if flipped:
		flip_mod = -1
	else:
		flip_mod = 1
	set_scale(Vector2(1 * flip_mod, 1))
	

