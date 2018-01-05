extends RigidBody2D
var name = "M14"
var named = "M14"

var base_value = 100
var value = 10

var slot = "primaryGun"
var weight = 5

var damage = 30.0
# 10 = 10
# of 100
var bulletspeed = 300
var stopping_power = 0
#10 = .5
# of 5
var fire_rate = .7
#10 = -.1
# of 1
var clip_capacity = 0.0
# of ammo_cap
var current_clip = 10.0
var reload_speed = 0
#10 = .4
# of 4
var distance = 150.0
# 10 = 50
# of 500

var distance_time = 0.0

var accuracy = 14.0
# 10 = 2
# of 20
var fullauto = true
var bullets_inbullets = 1
var volume = 10
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

var clip_gone = false

var pickup_area
var pickup = false
var player
var aiming = false
var is_equipped = false
var stats
var type = ""
var Global
var level

var trajectory = null
var effect = null
var effect_multiplier = 0

func stats():

	
	var fire_rated = round(fire_rate/1 * -100 + 100)
	var reload_speedd = round(reload_speed/4 * -100 + 100)
	var accuracyd = round(accuracy/20 * -100 + 100)
#	for items in [[fire_rated, fire_rate, 1], [reload_speedd, reload_speed, 4], [accuracyd, accuracy, 20]]:
#		if items[1] == 0:
#			items[2] = 100
#		elif items[1] == items[2]:
#			items[0] = 0 
#			
	var damaged = damage/ bullets_inbullets
	var distanced = round(distance/500.0 * 100)
	
	var list = [damaged, distanced, fire_rated, reload_speedd, accuracyd]
	var valued = 0
	for stat in list:
		valued += stat - 30
	 value = base_value + valued
	
#	var stopping_powerd = round(stopping_power/5 * 100)

#	for items in [[damaged, damaged, 100], [distanced, distance, 2], [stopping_powerd, stopping_power, 8]]:
#		if items[1] == 0:
#			items[2] = 0
#		elif items[1] == items[2]:
#			items[0] = 100 
#	var ammo_capacityd = "Ammo: " + str(round(ammo_capacity))
#	var clip_capacityd = "Mag: " + str(round(clip_capacity))
#	var effect = "Effect: " + str(effect)
	stats = [["Damage" + " X" +str(bullets_inbullets), damaged], ["Fire Rate", fire_rated],  ["Reload Speed", reload_speedd], ["Accuracy", accuracyd], ["Range", distanced]]
#, ["Stopping Power", stopping_powerd]
	return stats
	
func _ready():
	Global = get_node("/root/Global")
#	stats()
#stats.sort()
#	stats.push_front(damaged)
	set_fixed_process(true)
#	locked = true

func start():
	pass
#	ammo()

func bullettype():
	var new_bullet = Global.attacks.get_node(type + "/basic").duplicate()
	new_bullet = clip[0].bullet(new_bullet)
#	mod[0].bullet(new_bullet)
	new_bullet = barrel[0].bullet(new_bullet)
	new_bullet = mod[0].bullet(new_bullet)
	new_bullet.distance = distance/bulletspeed
	new_bullet.stopping_power = damage/.05 + stopping_power
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
	if (player.current_ammo + current_clip) < clip_capacity:
		current_clip = player.current_ammo
		player.current_ammo = 0
	elif current_clip > 0:
		player.current_ammo -= (clip_capacity - current_clip)
		current_clip = clip_capacity
	else:
		player.current_ammo -= clip_capacity
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
#	elif location == "special":
#		special.pop_back()
#	elif location == "melee":
#		melee_damage -= part.melee_damage
#		melee_type = ''
#		melee_stopping_power -= part.melee_stopping_power
#		melee.pop_front()
#		
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

func spawn():
	set_mode(0)
	set_layer_mask_bit(10, true)
	apply_impulse(Vector2(), Vector2(0, 5))
	is_equipped = false


func equipped():
	set_mode(1)
	set_layer_mask_bit(10, false)
	is_equipped = true

func drop():
	aiming(false, 0)
	var flip
#	var level = Global.player.level
	if get_parent() != null:
		flip = get_parent().get_parent().get_parent().get_parent().flip_mod
		if self in get_parent().get_parent().get_parent().get_parent().primaryGun:
			get_parent().get_parent().get_parent().get_parent().unequip_change("primaryGun")
		elif self in get_parent().get_parent().get_parent().get_parent().secondaryGun:
			get_parent().get_parent().get_parent().get_parent().unequip_change("secondaryGun")
		var rot = get_rotd()
		var pos = get_global_pos()
		self.get_parent().remove_child(self)
		set_global_pos(pos)
		set_rotd(rot)
		set_scale(Vector2(1 * flip, 1))
	else:
#		flip = Global.player.flip_mod
		set_global_pos(Vector2(Global.player.get_global_pos().x, Global.player.get_global_pos().y - 20))
		set_rotd(0)
		if is_equipped:
			set_scale(Vector2(1 * get_parent().get_parent().get_parent().flip_mod, 1))
#		if Global.on_supply_run:
#			Global.supply_run_pack.remove(Global.supply_run_pack.find(self))
#		else:
#			Global.pack.remove(Global.pack.find(self))
	level.add_child(self)
	set_mode(0)
	set_layer_mask_bit(10, true)
	apply_impulse(Vector2(), Vector2(0, 5))

	is_equipped = false

func description():
	var dam = "DPS: " + str(round(1/fire_rate * damage)) + "\n"
	var effectd
	if effect == null:
		effectd = "Effect: None"
	else:
		effectd = "Effect: " + effect
	var clip_cap = "Clip size: " + str(clip_capacity)
	return effectd + clip_cap

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
	if part.get_parent() != null:
		part.get_parent().remove_child(part)
	get_node("body").add_child(part)
	part.set_pos(get_node("body/" + location).get_pos())
	if location == "barrel":
		get_node("body/barrel_tip").set_pos(Vector2(get_node("body/barrel_tip").get_pos().x + part.barrel_size, get_node("body/barrel_tip").get_pos().y))
		get_node("body/Particles2D").set_pos(Vector2(get_node("body/barrel_tip").get_pos().x, get_node("body/Particles2D").get_pos().y))
		barrel.push_front(part)
	elif location == "clip":
		clip.push_front(part)
	elif location == "mod":
		mod.push_front(part)
#	elif location == "special":
#		special.push_front(part)
#	elif location == "melee":
#		melee_type = part.melee_type
#		melee_stopping_power += part.melee_stopping_power
#		melee.push_front(part)

	part.equip(self)
		
func generate(tier):
	var b = Global.gun_parts.get_node(tier).random("barrel")
#	var m = Global.gun_parts.get_node(tier).random("melee")
	var c = Global.gun_parts.get_node(tier).random("clip")
#	var sp = Global.gun_parts.get_node(tier).random("special")
	var sm = Global.gun_parts.get_node(tier).random("mod")
	equip(b, "barrel")
#	equip(m, "melee")
	equip(c, "clip")
#	equip(sp, "special")
	equip(sm, "mod")
	current_clip = round(rand_range(1, clip_capacity))
func shoot():
#	get_node("AnimationPlayer").play("Shoot")
	get_node("body/Particles2D").set_emitting(true)
	get_node("SamplePlayer2D").play("shoot")
	current_clip -= 1

func special_shoot():
#	get_node("AnimationPlayer").play("Shoot")
	player.current_ammo -= (player.ammo_capacity * special_ammo_cost)

#
#func pickmeup(collider):
#	if collider.is_in_group("players"):
#		pickup = true
#		get_node("Pickup/pick me up!").show()
#		player = collider
#		
#func cantpickmeup(collider):
#	if collider.get_name() != "TileMap" or collider.get_name() != "TileMap 2":
#		pickup = false
#		get_node("Pickup/pick me up!").hide()

func aiming(choice, number):
	get_node("body/RayCast2D").set_layer_mask(number) 
	get_node("body/RayCast2D").set_enabled(choice)
	set_fixed_process(true)
	aiming = choice
	
func _fixed_process(delta):
	if aiming:
		get_node("body/RayCast2D").set_cast_to(Vector2(distance, 0))
		if get_node("body/RayCast2D").is_colliding():
			get_node("body/RayCast2D/lazer_sight").set_scale(Vector2(get_node("body/RayCast2D/lazer_sight").get_global_pos().distance_to(get_node("body/RayCast2D").get_collision_point()), 1))
		else:
			get_node("body/RayCast2D/lazer_sight").set_scale(Vector2(get_node("body/RayCast2D").get_cast_to().x, 1))
	else:
		get_node("body/RayCast2D/lazer_sight").set_scale(Vector2(0, 1))

	if not aiming:
		set_fixed_process(false)
		
#func flip(flipped):
#	var flip_mod
#	if flipped:
#		flip_mod = -1
#	else:
#		flip_mod = 1
#	set_scale(Vector2(1 * flip_mod, 1))
	

