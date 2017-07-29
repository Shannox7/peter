extends Node2D
var BULLETSPEED = 500
var Gravity = 100
var gravitycounter = 20
var bullet
var opacity = 1
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
#	velocity.y += delta + accuracy 
#	velocity.x += delta + accuracy * flip_mod
	
	if drop == true:
		opacity -= .1
		get_node("Sprite").set_opacity(opacity)
		damage = 0
		stopping_power = 0
		if opacity <= 0:
			queue_free()
		
	move(velocity)
	
	if is_colliding():
		if drop == true:
			queue_free()
		else:
#		print (get_collider().get_name())
			if get_collider().get_name() == "TileMap" or get_collider().get_name() == "Obstacles" or get_collider().get_name() == "slope_left":
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
				get_collider().hit(self)
#			get_collider().add_child(bullet_humanoid)
				queue_free()