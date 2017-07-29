extends Node2D
var damage = 10
var stopping_power = 1
var fire_rate = 0.2
var clip_capacity = 50
var current_clip = 50
var ammo_capacity = 400
var current_ammo = 400
var reload_speed = 3
var distance = 1
var accuracy = 1
var fullauto = true
var bullet_list = []
var bullettype
var b = preload("res://PlayerAttacks.tscn")
var gp = preload("res://Gun_parts.tscn")
#var pu = preload("res://Pickup.tscn")
#var barrel_size .. use later maybe

var GRAVITY = 100
var velocity
var random
var flipped = false

var barrel
var sight
var clip
var special

var pickup_area
var pickup = false
var player
func _ready():

	get_node("Pickup/pick me up!").hide()
#	if get_parent() != null:
	if get_parent().get_parent().is_in_group("enemies"):
		bullettype("enemy")
	else:
		bullettype("player")
#	print (bullet_list)
#	print (current_clip)
func start():
	if get_parent() != null:
		for groups in get_parent().get_groups():
			print (groups)
			if groups == "enemy":
				bullettype("enemy")
				
				pass
	else:
		bullettype("player")
	current_clip = int(rand_range(1, clip_capacity))
	ammo()

func bullettype(identity):
	bullettype = b.instance().get_node("Unicorn")
	if identity == "enemy":
		bullettype.set_collision_mask_bit(2, false)
		bullettype.set_collision_mask(1)
		bullettype.set_layer_mask_bit(1, false)
		bullettype.set_layer_mask_bit(2, true)
	else:
		bullettype.set_collision_mask_bit(1, false)
		bullettype.set_collision_mask(2)
		bullettype.set_layer_mask_bit(1, false)
		bullettype.set_layer_mask_bit(2, true)
func ammo():
	for bullet in range(current_clip):
		var new_bullet = bullettype.duplicate()
		new_bullet.distance = distance
		var accuracy_skew = rand_range(-accuracy, accuracy)
		new_bullet.accuracy = accuracy_skew
		new_bullet.stopping_power = stopping_power
		new_bullet.damage = damage
		bullet_list.append(new_bullet)
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
	ammo()
func equip(part, location):
	damage += part.damage
	clip_capacity += part.clip_capacity
	reload_speed += part.reload_speed
	fire_rate += part.fire_rate
	accuracy += part.accuracy
	distance += part.distance
	stopping_power += part.stopping_power
	part.get_parent().remove_child(part)
	add_child(part)
	part.set_global_pos(get_node(location).get_global_pos())
	if location == "barrel":
		barrel = part
	elif location == "sight":
		sight = part
	elif location == "clip":
		clip = part
	elif location == "special":
		special = part
func generate(tier):
#add tier
#barrel
	print("barrel time")
	var b = gp.instance().get_node(tier).random("barrel")
	var s = gp.instance().get_node(tier).random("sight")
	var c = gp.instance().get_node(tier).random("clip")
	var sp = gp.instance().get_node(tier).random("special")
	equip(b, "barrel")
	equip(s, "sight")
	equip(c, "clip")
	equip(sp, "special")
func shoot():
	current_clip -= 1
	bullet_list.pop_back()

func unlock():
	set_fixed_process(true)
	set_process_input(true)
	random = rand_range(-.05, .05)
	pickup = false
	pickup_area = get_node("Pickup")
	pickup_area.show()
	pickup_area.connect("body_enter", self, "pickmeup")
	pickup_area.connect("body_exit", self, "cantpickmeup")
	
func lock():
	set_fixed_process(false)
	set_process_input(false)
	get_node("CollisionShape2D").set_trigger(true)
	get_node("Pickup").hide()
	pickup_area.disconnect("body_enter", self, "pickmeup")
	pickup_area.disconnect("body_exit", self, "cantpickmeup")
	pickup = false
#	print('we locked')
	
func pickmeup(collider):
	if collider.get_name() == "Peter":
		pickup = true
		get_node("Pickup/pick me up!").show()
		player = collider
		
func cantpickmeup(collider):
	if collider.get_name() != "TileMap" or collider.get_name() != "TileMap 2":
		pickup = false
		get_node("Pickup/pick me up!").hide()

func _fixed_process(delta):
	velocity = Vector2()
	velocity.y += delta * GRAVITY
	get_node("CollisionShape2D").set_trigger(false)
		
	if is_colliding():
		pass
	else:
		rotate(random)
	move(velocity)
func flip():
	if flipped:
		get_node("Sprite").set_flip_h(true)

		barrel.set_pos(Vector2(get_node("barrel").get_pos().x * -1, get_node("barrel").get_pos().y))
		sight.set_pos(Vector2(get_node("sight").get_pos().x * -1, get_node("sight").get_pos().y))
		clip.set_pos(Vector2(get_node("clip").get_pos().x * -1, get_node("clip").get_pos().y))
		special.set_pos(Vector2(get_node("special").get_pos().x * -1, get_node("special").get_pos().y))
		special.set_flip_h(true)
		barrel.set_flip_h(true)
		sight.set_flip_h(true)
		clip.set_flip_h(true)
	else:
		get_node("Sprite").set_flip_h(false)
		barrel.set_pos(Vector2(get_node("barrel").get_pos().x, get_node("barrel").get_pos().y))
		sight.set_pos(Vector2(get_node("sight").get_pos().x, get_node("sight").get_pos().y))
		clip.set_pos(Vector2(get_node("clip").get_pos().x, get_node("clip").get_pos().y))
		special.set_pos(Vector2(get_node("special").get_pos().x, get_node("special").get_pos().y))
		special.set_flip_h(false)
		barrel.set_flip_h(false)
		sight.set_flip_h(false)
		clip.set_flip_h(false)
	
func _input(event):
	if event.is_action_pressed("pickup") and pickup == true:
		lock()
		player.equip(self)
