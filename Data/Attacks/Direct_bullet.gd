extends "res://Data/Attacks/Attacks.gd"
var frame = 2
var target = null
var ray
#var drop = false
var pierce = false

func _ready():
	initialize()
	ray = get_node("RayCast2D")
	var new_vector = Vector2(bulletspeed * distance, 0)
	ray.set_cast_to(new_vector)
#	ray.set_global_pos(get_pos())
	ray.set_scale(Vector2(1 * flip_mod , 1))
	target = Vector2(get_node("RayCast2D").get_cast_to().x, 0)
	velocity = Vector2(0,0)
func effect(collider, hit):
	var random = round(rand_range(0, 100))
	if hit:
		collider.hit(self)
#		if random > 0:
#			ray.add_exception(collider)
#			pierce = true
	pierce = false
		
	pass
#	hit_effect(collider, hit)
#
#func pierce():
#	
#	pass
	
func _fixed_process(delta):
#	set_rot(get_node("RayCast2D")
	if frame <= 0 and not drop:
		colliding(ray)
		if not pierce:
			get_node("RayCast2D").set_enabled(false)
			drop = true
	else:
		frame -= 1
		
	if drop:
		fade(delta)



func fade(delta):
	opacity -= delta
	get_node("Sprite").set_opacity(opacity)
	get_node("Particles2D").set_opacity(opacity)
	if visual_effect != null:
		visual_effect.set_opacity(opacity)
	if opacity <= 0:
		queue_free()
	
func colliding(collider):
	if collider.is_colliding():
		target = Vector2(get_global_pos().distance_to(get_node("RayCast2D").get_collision_point()),0 )
		get_node("Sprite").set_scale(Vector2(get_global_pos().distance_to(get_node("RayCast2D").get_collision_point()) * flip_mod, 1))
		if collider.get_collider().is_in_group("inanimate"):
			effect("no_hit", false)
		else:
			if flip_mod == -1:
				flip_effect = true
			else:
				flip_effect = false
			if collider.get_collider().has_method("hit"):
				effect(collider.get_collider(), true)
			else:
				effect(collider.get_collider().get_parent(), true)
	else:
		var target = get_node("RayCast2D").get_cast_to()
	print(target)
	get_node("Sprite").set_scale(Vector2(target.x * flip_mod, get_scale().y))
	get_node("Particles2D").set_emissor_offset(Vector2(target.x/2 * flip_mod, 0))
	get_node("Particles2D").set_emission_half_extents((Vector2(target.x/2 * flip_mod, 0)))
	get_node("Particles2D").set_emitting(true)
	if visual_effect != null:
		visual_effect.set_emission_half_extents((Vector2(target.x/2 * flip_mod, 2)))
		visual_effect.set_emissor_offset(Vector2(target.x/2 * flip_mod, 0))
		visual_effect.set_param(0, 90 * flip_mod)
		visual_effect.set_emitting(true)