extends KinematicBody2D
var BULLETSPEED = 500
var Gravity = 100
var gravitycounter = 20
var bullet
var flip_mod = 1
var damage = 0
var stopping_power = 0
var accuracy = 0
var distance = 10
var distance_timer
var velocity
var bh = preload("res://effects.tscn")
var bullet_humanoid
var flip_effect
var drop = false
var opacity = 1

func _ready():
	var bullethole = bh.instance()
	bullet_humanoid = bullethole.get_node("Bullethole_r_human").duplicate()
	distance_timer = get_node("Distance")
	distance_timer.set_wait_time(distance)
	distance_timer.connect("timeout", self, "Drop")

	distance_timer.start()
	set_fixed_process(true)

func hit(damage, s, d, f, g, h):
	pass

func Drop():
	drop = true

func _fixed_process(delta):
	velocity = Vector2(cos(get_rot()) * delta * BULLETSPEED * flip_mod, -sin(get_rot()) * delta * BULLETSPEED * flip_mod)
	velocity.y += delta + accuracy 
	velocity.x += delta + accuracy
	
	if drop == true:
#		velocity.y += delta * Gravity
#		velocity.x += delta * -Gravity * flip_mod 
#		Gravity += 1
#		if velocity.x <= 0.2 and flip_mod == 1:
#			velocity.x = 0
#		elif flip_mod == -1 and velocity.x >= .02:
#			velocity.x = 0
#		print(velocity.x)
		opacity -= .1
		get_node("Sprite").set_opacity(opacity)
		damage = 0
		stopping_power = 0
		if opacity <= 0:
			queue_free()
		
	move(velocity)
	
	if is_colliding():
#		print (get_collider().get_name())
		if drop == true:
			queue_free()
		if get_collider().get_name() == "TileMap" or get_collider().get_name() == "Obstacles" or get_collider().get_name() == "slope_left":
#			get_collider().add_child(bullet_humanoid)
			free()
		else:
#			bullet_humanoid.set_pos(get_pos())
#			bullet_humanoid.set_rotd(get_rotd())
#			bullet_humanoid.set_z(1)
			if flip_mod == -1:
				flip_effect = true
			else:
				flip_effect = false
			get_collider().hit(self)
#			get_collider().add_child(bullet_humanoid)
			queue_free()

		
