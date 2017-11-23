extends Area2D
#var BULLETSPEED = 500
var shrapnel = []
var shrapnelnumber = 0
var damage = 0
var stopping_power = 2
var distance = .5
var distance_timer
var velocity = Vector2()
var bh = preload("res://effects.tscn")
var attacks = preload("res://Attacks.tscn")
var targets = [] 
var time = 1
var frag_speed = 300
var blown_up = false

var faction
var drop = false

var effect = null
var effect_multiplier = 0
func _ready():
	get_node("Particles2D").set_emitting(true)
	set_fixed_process(true)
	pass

func effect(collider, hit):
	if hit:
		collider.hit(self)

#func find(collider):
#	if collider.is_in_group("enemies"):
#		targets.append(collider)
#	elif collider.is_in_group("explosives"):
#		collider.blow()
#func hurt():
#	for enemies in targets:
#		if enemies == null:
#			pass
#		else:
#			velocity = Vector2(cos(get_angle_to(enemies.get_pos())), -sin(get_angle_to(enemies.get_pos())))
#			enemies.hit(self)
#	queue_free()
func _fixed_process(delta):
	time -= 1
	if time == 0:
		for shrap in range(shrapnelnumber):
			var frags = attacks.instance().get_node("Shrapnel").duplicate()
			frags.damage = 1
			frags.bulletspeed = frag_speed
			frags.set_collision_mask_bit(faction.enemynumber, true)
			frags.set_collision_mask_bit(faction.enemynumber * 3, true)
			frags.set_rotd(rand_range(0, 360))
			frags.set_global_pos(get_global_pos())
			get_parent().add_child(frags)
		for collider in get_overlapping_bodies():
			if collider.is_in_group("inanimate"):
				effect("no_hit", false)
			else:
				if collider.has_method("hit"):
					effect(collider, true)
				else:
					effect(collider.get_parent(), true)
	if not get_node("Particles2D").is_emitting():
		queue_free()

