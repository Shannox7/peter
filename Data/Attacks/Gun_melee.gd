extends RayCast2D
var damage = 0
var stopping_power = 0
var enemyside
var time = .25
var attacker
var velocity = Vector2(0, 0)
var drop = false
#var rotate = 45
func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
#	rotate -= 4
#	stopping_power
	velocity = Vector2(cos(get_parent().get_rot()) * 500 * delta  * attacker.flip_mod, -sin(get_parent().get_rot()) * delta * attacker.flip_mod)
#	velocity = attacker.get_node("Arm").get_rotd()
#	set_pos(spawn_point)
	time -= delta
	if time <= 0:
		queue_free()
	if is_colliding():
#		print("colliding")
		if not get_collider().is_in_group("inanimate"):
			get_collider().get_parent().hit(self)
			add_exception(get_collider())