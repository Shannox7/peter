extends RayCast2D
var damage = 0
var stopping_power = 0
var enemyside
var time = .25
var attacker
var velocity = Vector2(0, 0)
var drop = false
#var rotate = 45
var effect = null
var effect_multiplier = 0
var player = null
var critical = false
var poison = 0

	
func blood():
	var blood = get_node("/root/Global").effects.get_node("Blood_splatter").duplicate()
	var blood_drop = get_node("/root/Global").effects.get_node("blood").duplicate()
	blood.set_pos(get_collision_point())
	blood_drop.set_pos(get_collision_point())
#	blood.set_scale(Vector2(1 * flip_mod, 1))

	get_parent().get_parent().get_parent().level.add_child(blood)
	get_parent().get_parent().get_parent().level.add_child(blood_drop)
	blood.set_param(0, rad2deg(blood.get_angle_to(get_pos()) - 3.14159/2))
#	blood.set_rotd(blood.get_rotd() * - 1)
	blood.set_emitting(true)
	
func hit_pierce_effect(collider, hit):
	if hit:
		blood()
		collider.hit(self)
	
func hit_effect(collider, hit):
	if hit:
		blood()
		collider.hit(self)

		call_deferred("queue_free")
		
func colliding():
	if is_colliding():
		if get_collider().is_in_group("inanimate"):
			effect("no_hit", false)
		elif get_collider().has_method("hit"):
			add_exception(get_collider())
			add_exception(get_collider().get_parent().get_parent())
			effect(get_collider(), true)
		else:
			add_exception(get_collider())
			effect(get_collider().get_parent(), true)