extends "res://Data/Enemy.gd"
func _ready():
	create()

	
func chase():
	if chase == false:
		orders("chase")
		level.chase_list.append(myself)
	if not scream:
		get_node("AnimationPlayer").play("scream")
		get_node("SamplePlayer2D").play("scream")
		scream = true
		scream_delay = total_scream_delay



			
func _fixed_process(delta):
	reset()
	gravity_check(delta)
	grounded_check()
	reloading(delta)
#	if primaryGun != [] and target_list == [] and low_priority_list == [] or (primaryGun != [] and dead):
#		primaryGun[0].aiming(false, faction.enemynumberval)

#	if dead:
#		die(delta)
	if stunned:
		pass
#	elif wait:
#		holding = true
#		wait(delta)
#	elif retreat:
#		go_to(objective)
	elif chase:
		if target_list == []:
			chase = false
			alerted = false
			orders("patrol")
			look.set_layer_mask(14)
		else:
			var target = target_list.front().get_ref()
			if scream:
				scream(delta)
			if check_ref(target):
				target_list.pop_front()
			else:
				var targeting = target.get_node("body")
#				look(targeting)
				attack(targeting)
				if check_ref(target):
					target_list.pop_front()
				else:
					navigate(target.get_global_pos())
					if get_pos().distance_to(targeting.get_global_pos()) < 30:
						raycast.set_rot(get_angle_to(targeting.get_global_pos()) - 3.14159/2)
	elif target_list != []:
		var target = target_list.front().get_ref()
		if check_ref(target):
			target_list.pop_front()
		else:
			find_target(target.get_node("body"))
					
	elif investigate:
		navigate(objective)
		if get_global_pos().distance_to(objective) < 10:
			orders("patrol")
	elif attack:
		go_to(objective)
	elif patrol:
		patrol(delta)

	
	if not stunned:
		flip_check()
		jumping(delta, height)
		moving(delta)
	if not dead:
		the_movement(delta)
	animate()
	knockback()
	if effect != null:
		effect(delta)