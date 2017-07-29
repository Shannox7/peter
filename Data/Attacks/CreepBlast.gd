extends KinematicBody2D
export var ATTACKSPEED = 60
var Blast
var flip_mod = 1

var damage = 2
#var flipped = false

#func flip():
#	get_node("bullet").set_flip_h(flipped)
#	flipped = !flipped
#	flip_mod = flip_mod * -1

#var enemy = preload("res://Enemies.tscn")
var distance

func _ready():
	set_fixed_process(true)
#	var distance = get_node("Range")
#	distance.set_wait_time(.5)
#	distance.connect("timeout", self, "free_me")
#	add_collision_exception_with(enemy.get_node("Zombie"))
#	add_collision_exception_with(get_parent().get_node("CreepBlast"))
#func free_me():
#	print("free")
#	queue_free()

func _fixed_process(delta):
	move(Vector2(cos(get_rot()) * delta * ATTACKSPEED * flip_mod, -sin(get_rot()) * delta * ATTACKSPEED * flip_mod))

	if is_colliding():
		if get_collider().get_name() == "Peter":
			get_collider().hurt(damage)
			queue_free()
		else:
			queue_free()