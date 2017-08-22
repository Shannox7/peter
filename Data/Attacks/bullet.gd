extends Node2D
var bulletspeed = 0
var Gravity = 20
var gravitycounter = 20
var bullet
var countdown = 2
var flip_mod = 1
var damage = 0
var stopping_power = 0
var accuracy = 0
var distance = 1
#var distance_timer
var velocity
var bh = preload("res://effects.tscn")
var bullet_humanoid
var flip_effect
var drop = false
var random
var damage_fraction
var bulletspeed_fraction
var random_drop_range
var side
#query space instead of collider
func _ready():
	var bullethole = bh.instance()
	bullet_humanoid = bullethole.get_node("Bullethole_r_human").duplicate()
	set_fixed_process(true)
#	distance_timer = get_node("Distance")
#	distance_timer.set_wait_time(distance)
#	distance_timer.connect("timeout", self, "Drop")
#	distance_timer.start()
#	random = rand_range(5, 10)
	random_drop_range = rand_range(100, 200)
	damage_fraction = damage/100.0
	bulletspeed_fraction = bulletspeed/100
	bulletspeed += rand_range(bulletspeed_fraction * -10 , bulletspeed_fraction* 10)

func Drop():
	drop = true

func _fixed_process(delta):
	distance -= delta
	velocity = Vector2(cos(get_rot()) * delta * bulletspeed * flip_mod, -sin(get_rot()) * delta * bulletspeed * flip_mod)

#	print (bulletspeed_fraction)
	
	if distance <= 0:
		drop = true
		get_node("Sprite").set_offset(Vector2(0, 2))
		get_node("Sprite").set_centered(true)
		get_node("CollisionShape2D").set_pos(Vector2(0, 0))
		get_node("Sprite").rotate(-.1 * flip_mod)
#		bulletspeed = 300
#		if get_rotd() > -80 or get_rotd() < -100: 
#			rotate(-.01 *flip_mod)
		damage -= damage_fraction
#		bulletspeed -= bulletspeed_fraction
		stopping_power = 0
		velocity.y += Gravity * delta
		Gravity += 2
#		bulletspeed = 200
		if bulletspeed < bulletspeed_fraction * 25:
#			bulletspeed = 100
			bulletspeed = bulletspeed_fraction * 25
		else:
			bulletspeed -= bulletspeed_fraction
#				bulletspeed = 10
		if damage <= 0:
			damage = 0
#			queue_free()
#		print (damage)  
		if countdown <= 0:
			queue_free()
	move(velocity)
	if is_colliding():
#		print (get_collider().get_name())
		if get_collider().is_in_group("inanimate"):
			queue_free()
		else:
			if flip_mod == -1:
				flip_effect = true
			else:
				flip_effect = false
#				if get_collider().is_in_group("players") or get_collider().is_in_group("allies"):
			get_collider().hit(self)
#			get_collider().add_child(bullet_humanoid)
			
#			get_collider().add_child(bullet_humanoid)
#				if get_collider().is_in_group("players") or get_collider().is_in_group("allies"):

#			get_collider().add_child(bullet_humanoid)
			queue_free()
#			bullet_humanoid.set_pos(get_pos())
#			bullet_humanoid.set_rotd(get_rotd())
#			bullet_humanoid.set_z(1)
