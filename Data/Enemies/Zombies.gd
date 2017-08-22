extends "res://Data/Basic_infantry.gd"

var limbs = preload("res://Limbs.tscn")



#func action():
#	var random = int(rand_range(1, 4))
#	timer.set_wait_time(wait_time)
#	idle = false
#	if random == 1:
#		idle = true
#	elif random == 2:
#		pass 
#	elif random == 3:
#		man_flip()
	
func health():
	var scale = 3
	if health > 0.0:
		health_display.set_scale(Vector2(1, (health/total_health) * scale)) 
		if health/total_health > 0.25:
			health_display.set_modulate(Color(0, 255, 0))
		elif health/total_health <= 0.25:
			health_display.set_modulate(Color(255, 0, 0))
	else:
		health_display.set_scale(Vector2(1, 0))
		health_display.set_modulate(Color(255, 0, 0))
#		


func die(delta):
	deathTime -= delta
	if get_rotd() > -90 and get_rotd() < 90:  
		rotate(.05 * flip_mod)
		holding = true
	if deathTime <= 0:
		queue_free()


	
func dismember(anatomy):
	var limb = limbs.instance()
	var arm_right = limb.get_node("z_arm_r").duplicate()
	var arm_left = limb.get_node("z_arm_l").duplicate()
	var headz = limb.get_node("z_head").duplicate()
	var torsoz = limb.get_node("z_torso").duplicate()
	var new_limb
	if anatomy == arm_r:
		dropGun()
		new_limb = arm_right
	elif anatomy == arm_l:
		new_limb = arm_left
	elif anatomy == head:
		new_limb = headz
	elif anatomy == torso:
		new_limb = torsoz 
	new_limb.set_global_pos(anatomy.get_global_pos())
	new_limb.set_rotd(anatomy.get_rotd())
	if flipped:
		new_limb.get_node("Sprite").set_flip_h(true)
		new_limb.flip_mod = - 1
	get_parent().add_child(new_limb)
	

		

func death():
	var number = 0
	get_parent().enemy_list.remove(get_parent().enemy_list.find(self))
	var hold_range = 30
	var hold_order = 1
	for enemys in get_parent().enemy_list:
		enemys.hold_range = hold_range * hold_order
		hold_order += 1
	get_node("body").set_layer_mask_bit(enemynumber, false)

#	get_node("CollisionShape2D").set_trigger(true)
	dead = true
#	get_parent().death(self)
#			print ("taking out the traaaaaaaash")
	if right_arm_gone == false:
		dropGun()
			
func original_colour():
	hit = false
	arm_l.set_modulate(Color(1, 1, 1))
	arm_r.set_modulate(Color(1, 1, 1))
	head.set_modulate(Color(1, 1, 1))
	torso.set_modulate(Color(1, 1, 1))
	legs.set_modulate(Color(1, 1, 1))

func red():
	get_node("hit_timer").start()
	arm_l.set_modulate(Color(255,0, 0))
	arm_r.set_modulate(Color(255,0, 0))
	head.set_modulate(Color(255,0, 0))
	torso.set_modulate(Color(255,0, 0))
	legs.set_modulate(Color(255,0, 0))
	
func hit(collider):
#	if collider.get_global_pos().y < collider.get_global_pos().y:
#		print ("critical")
#		collider.damage = collider.damage * 2
	red()
	if collider.drop != true:
		var random = int(rand_range(0, 5))
		if (random == 1 and right_arm_gone == false):
			right_arm_gone = true
			dismember(arm_r)
		elif (random == 2 and left_arm_gone == false):
			left_arm_gone = true
			dismember(arm_l)
	if hit == false:
		knockback_velocity.x = collider.velocity.x * collider.stopping_power
		knockback_velocity.y = collider.velocity.y * collider.stopping_power
	hit = true
	health -= collider.damage
	if health <= 0 and not dead:
		death()
	health()
	
