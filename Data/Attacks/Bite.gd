extends Node2D
export var ATTACKSPEED = 500
var bh = preload("res://effects.tscn")
var Bite
var flip_mod = 1
var damage = 1
var stopping_power = 5
var accuracy = 0
var velocity
var position
var bullethole
var flip_effect
var bullet_humanoid
#var flipped = false

#func flip():
#	get_node("bullet").set_flip_h(flipped)
#	flipped = !flipped
#	flip_mod = flip_mod * -1

#var enemy = preload("res://Enemies.tscn")
var distance
var distance_timer
func _ready():
	set_fixed_process(true)
	distance_timer = get_node("Range")
#	distance.set_wait_time(.025)
#	distance.connect("timeout", self, "free_me")
#	add_collision_exception_with(enemy.get_node("Zombie"))
	distance_timer.connect("timeout", self, "queue_free")
	distance_timer.set_wait_time(distance)
	distance_timer.start()
	add_collision_exception_with(get_parent().get_node("Bite"))
	bullethole = bh.instance()
	bullet_humanoid = bullethole.get_node("Bullethole_r_human").duplicate()
	
func hit(damage):
	pass
#func free_me():
#	print("free")
#	set_fixed_process(false)
#	queue_free()

func _fixed_process(delta):
	velocity = Vector2(cos(get_rot()) * delta * ATTACKSPEED * flip_mod, -sin(get_rot()) * delta * ATTACKSPEED * flip_mod)
	move(velocity)
	
	if is_colliding():
		if get_collider().is_in_group("players"):
			if flip_mod == -1:
				flip_effect = true
			else:
				flip_effect = false
			get_collider().hit(self)
			queue_free()
#		else:
#			get_collider().hit(damage)
#			queue_free()
		else:
			queue_free()
		