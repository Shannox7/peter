extends Node2D
var BULLETSPEED = 500
var Gravity = 100
var gravitycounter = 20
var bullet
var flip_mod = 1
var damage = 0
var stopping_power = 0
var accuracy = 0
var distance = 1
var distance_timer
var velocity
var bh = preload("res://effects.tscn")
var bullet_humanoid
var flip_effect
var drop = false
#query space instead of collider
func _ready():
	var bullethole = bh.instance()
	bullet_humanoid = bullethole.get_node("Bullethole_r_human").duplicate()
	set_fixed_process(true)
	distance_timer = get_node("Distance")
	distance_timer.set_wait_time(distance)
	distance_timer.connect("timeout", self, "Drop")
	distance_timer.start()
func hit(collider):
	pass

func Drop():
	drop = true

func _fixed_process(delta):
	velocity = Vector2(cos(get_rot()) * delta * BULLETSPEED * flip_mod, -sin(get_rot()) * delta * BULLETSPEED * flip_mod)
	velocity.y += delta + accuracy 
	velocity.x += delta + accuracy * flip_mod
	
	if drop == true:
		velocity.y += delta * Gravity
		velocity.x += delta * -Gravity * flip_mod 
		Gravity += 1
		if velocity.x <= 0.2 and flip_mod == 1:
			velocity.x = 0
		elif flip_mod == -1 and velocity.x >= .02:
			velocity.x = 0
#		print(velocity.x)
		get_node("Sprite").rotate(.25)
		damage = 0
		stopping_power = 10
		
	move(velocity)
	
	if is_colliding():
		if drop == true:
			queue_free()
		else:
#		print (get_collider().get_name())
			if get_collider().is_in_group("inanimate"):
#			get_collider().add_child(bullet_humanoid)
				queue_free()
			elif get_collider().is_in_group("bullets"):
				add_collision_exception_with(get_collider())
				print ("bullet is colliding with a bullet")
			else:
#			bullet_humanoid.set_pos(get_pos())
#			bullet_humanoid.set_rotd(get_rotd())
#			bullet_humanoid.set_z(1)
				if flip_mod == -1:
					flip_effect = true
				else:
					flip_effect = false
#				if get_collider().is_in_group("players") or get_collider().is_in_group("allies"):
				get_collider().hit(self)
#			get_collider().add_child(bullet_humanoid)
				queue_free()