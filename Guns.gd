extends KinematicBody2D

var name = "M14"
var named = "M14"
var gun_size = 20
var value = 10
var damage = 1
var melee_damage = 0
var melee_stopping_power = 2
var bulletspeed = 500
var stopping_power = 1
var fire_rate = 0.1
var clip_capacity = 120
var current_clip = 120
var ammo_capacity = 400
var current_ammo = 400
var is_equipped = false
var stats
var reload_speed = 3
var distance = .5
var accuracy = 2
var fullauto = false
var bullets_inbullets = 1
var bullet_list = []
var bullettype
var b = preload("res://Attacks.tscn")
var gp = preload("res://Gun_parts.tscn")
#var pu = preload("res://Pickup.tscn")

var countdown = 10
var GRAVITY = 100
var velocity
var random
var flipped = false
var locked = true
var barrel = []
var sight = []
var clip = []
var special = []

var pickup_area
var pickup = false
var player

var aiming = false
func _ready():
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
	get_node("Pickup/pick me up!").hide()
	bullettype()
	set_fixed_process(true)
#	locked = true
#	print (bullet_list)
#	print (current_clip)
func start():
	bullettype()
	current_clip = int(rand_range(1, clip_capacity))
#	ammo()
func bullettype():
	var new_bullet = b.instance().get_node("Bullet").duplicate()
#	new_bullet = clip[0].bullet(new_bullet)
	special[0].bullet(new_bullet)
	barrel[0].bullet(new_bullet)
	new_bullet.distance = distance
	new_bullet.stopping_power = stopping_power
	new_bullet.damage = damage
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
	if (current_ammo - current_clip) < clip_capacity:
		current_clip = current_ammo
		current_ammo = 0
	elif current_clip > 0:
		bullet_list.clear()
		current_ammo -= (clip_capacity - current_clip)
		current_clip = clip_capacity
	else:
		current_ammo -= clip_capacity
		current_clip = clip_capacity
#	ammo()
func unequip(part, location):
	damage -= part.damage
	clip_capacity -= part.clip_capacity
	reload_speed -= part.reload_speed
	fire_rate -= part.fire_rate
	accuracy -= part.accuracy
	distance -= part.distance
	stopping_power -= part.stopping_power
	if part.fullauto != null:
		!fullauto
	if location == "barrel":
		gun_size -= part.barrel_size
		barrel.pop_back()
	elif location == "sight":
		sight.pop_back()
	elif location == "clip":
		clip.pop_back()
	elif location == "special":
		special.pop_back()
func equip_display(part, location):
	part.get_parent().remove_child(part)
	add_child(part)
	part.set_global_pos(get_node(location).get_global_pos())
func equip(part, location):
	damage += part.damage
	clip_capacity += part.clip_capacity
	reload_speed += part.reload_speed
	fire_rate += part.fire_rate
	accuracy += part.accuracy
	distance += part.distance
	stopping_power += part.stopping_power
	if part.fullauto != null:
		fullauto = part.fullauto
	part.get_parent().remove_child(part)
	add_child(part)
	part.set_pos(get_node(location).get_pos())
	if location == "barrel":
		gun_size += part.barrel_size
		get_node("barrel_tip").set_pos(Vector2(get_node("barrel_tip").get_pos().x + part.barrel_size, get_node("barrel_tip").get_pos().y))
		barrel.push_front(part)
	elif location == "sight":
		sight.push_front(part)
	elif location == "clip":
		clip.push_front(part)
	elif location == "special":
		special.push_front(part)
#	print (barrel[0])
		
func generate(tier):
	var b = gp.instance().get_node(tier).random("barrel")
	var s = gp.instance().get_node(tier).random("sight")
	var c = gp.instance().get_node(tier).random("clip")
	var sp = gp.instance().get_node(tier).random("special")
	equip(b, "barrel")
	equip(s, "sight")
	equip(c, "clip")
	equip(sp, "special")
func shoot():
#	var shooter = get_parent().get_parent()
#	var flip_mod = shooter.flip_mod
#	var Aimrot = get_parent().get_rot() * flip_mod
#	var pos = Vector2(cos(Aimrot), -sin(Aimrot)) * flip_mod
#	var spawn_point = pos + get_node("barrel_tip").get_global_pos()
#	for bullets in bullet_list.back():
#		if flip_mod == -1:
#			bullets.get_node("Sprite").set_flip_h(true)  
#			bullets.flip_mod = -1
#		bullets.set_rotd(rad2deg(Aimrot) + rand_range(accuracy, -accuracy))
#		bullets.set_collision_mask(shooter.enemynumber)
#		bullets.set_pos(spawn_point)
#		bullets.side = shooter.side
#		shooter.get_parent().get_parent().add_child(bullets)
	current_clip -= 1
	bullet_list.pop_back()

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
	get_node("RayCast2D").set_layer_mask(number)
	get_node("RayCast2D").set_enabled(choice)
	set_fixed_process(true)
	aiming = choice
	
func _fixed_process(delta):
	if aiming:
		get_node("RayCast2D").set_cast_to(Vector2(bulletspeed * distance, 0))
		if get_node("RayCast2D").is_colliding():
			get_node("RayCast2D/lazer_sight").set_scale(Vector2(get_node("RayCast2D/lazer_sight").get_global_pos().distance_to(get_node("RayCast2D").get_collision_point()), 1))
		else:
			get_node("RayCast2D/lazer_sight").set_scale(Vector2(get_node("RayCast2D").get_cast_to().x, 1))
	else:
		get_node("RayCast2D/lazer_sight").set_scale(Vector2(0, 1))
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
#	get_node("Sprite").set_flip_h(flipped)
	set_scale(Vector2(1 * flip_mod, 1))
#	get_node("barrel").set_pos(get_node("barrel").get_pos().x * flip_mod)
#	barrel[0].set_scale(Vector2(1 * flip_mod, 1))
#	barrel[0].set_pos(Vector2(get_node("barrel").get_pos().x * flip_mod, get_node("barrel").get_pos().y))
#	sight[0].set_pos(Vector2(get_node("sight").get_pos().x * flip_mod, get_node("sight").get_pos().y))
#	clip[0].set_pos(Vector2(get_node("clip").get_pos().x * flip_mod, get_node("clip").get_pos().y))
#	special[0].set_pos(Vector2(get_node("special").get_pos().x * flip_mod, get_node("special").get_pos().y))
#	special[0].set_flip_h(flipped)
#	barrel[0].set_flip_h(flipped)
#	sight[0].set_flip_h(flipped)
#	clip[0].set_flip_h(flipped)
	
func _input(event):
	if event.is_action_pressed("equip") and pickup == true:
		lock()
		self.get_parent().remove_child(self)
		player.equip(self, true, "primaryGun")
	elif event.is_action_pressed("pickup") and pickup == true:
		lock()
		self.get_parent().remove_child(self)
		player.pack.append(self)
#		print(player.pack)
