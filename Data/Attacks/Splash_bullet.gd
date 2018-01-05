extends "res://Data/Attacks/Attacks.gd"
var frame = 2
var target = null
var detect
#var drop = false
var pierce = false
var wait = false

func _ready():
	initialize()
	get_node("RayCast2D").set_cast_to(Vector2(bulletspeed * distance * flip_mod, 0))
	detect = get_node("Area2D")
	detect.set_collision_mask_bit(2, get_collision_mask_bit(2))
	detect.set_collision_mask_bit(1, get_collision_mask_bit(1))
	var new_vector = Vector2(bulletspeed * distance, 10)
	detect.set_scale(Vector2(new_vector.x/2, 10))
	detect.set_pos(Vector2(new_vector.x/2 * flip_mod, 0))
	target = new_vector
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
		if get_node("RayCast2D").is_colliding() and not wait:
			var new_vector = Vector2(get_global_pos().distance_to(get_node("RayCast2D").get_collision_point()),0 )
			detect.set_scale(Vector2(new_vector.x/2, 10))
			detect.set_pos(Vector2(new_vector.x/2 * flip_mod, 0))
			target = new_vector
			frame = 1
			wait = true
		if frame <= 0:
			colliding()
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
	
func colliding():
	for collider in get_node("Area2D").get_overlapping_bodies():
		if collider.is_in_group("inanimate") or collider.is_in_group("critical"):
			effect("no_hit", false)
		else:
			if flip_mod == -1:
				flip_effect = true
			else:
				flip_effect = false
			if collider.has_method("hit"):
				effect(collider, true)
			else:
				effect(collider.get_parent(), true)
#	else:
#		var target = get_node("RayCast2D").get_cast_to()
#	print(target)
#	get_node("Sprite").set_scale(Vector2(target.x * flip_mod, get_scale().y))
	get_node("Particles2D").set_emissor_offset(Vector2(target.x/2 * flip_mod, 0))
	get_node("Particles2D").set_emission_half_extents((Vector2(target.x/2 * flip_mod, 0)))
	get_node("Particles2D").set_param(0, 90 * flip_mod)
	get_node("Particles2D").set_emitting(true)
	if visual_effect != null:
		visual_effect.set_emission_half_extents((Vector2(target.x/2 * flip_mod, 10)))
		visual_effect.set_emissor_offset(Vector2(target.x/2 * flip_mod, 0))
		visual_effect.set_param(0, 90 * flip_mod)
		visual_effect.set_emitting(true)
		