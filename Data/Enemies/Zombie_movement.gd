extends "res://Data/Enemy.gd"

var track_time = 2

func _ready():
	create()



func _fixed_process(delta):
#	reset()
	gravity_check(delta)
	grounded_check()


#	if target_list == [] and primaryGun != []:
#		primaryGun[0].aiming(false, faction.enemynumberval)
	
	if spawning:
		spawn_fade(delta)

#	if dead:
#		die(delta)
	elif stunned:
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
			if primaryGun != []:
				primaryGun[0].aiming(false, faction.enemynumberval)
		else:
			var target = target_list.front().get_ref()
			if check_ref(target):
				target_list.pop_front()
			else:
				var targeting = target.get_node("body")
#				look(targeting)
				attack(targeting)
				reloading(delta)
				if check_ref(target):
					target_list.pop_front()
				else:
					navigate(target.get_global_pos())
					if get_pos().distance_to(targeting.get_global_pos()) < 30:
#						look(targeting)
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
#	elif attack:
#		go_to(objective)
	elif patrol:
		patrol(delta)
	
	if target_list != []:
		track_time -= delta
		if track_time <= 0:
			track_time = 2
			track_closest(target_list)
	if left_leg_gone and left_arm_gone and right_leg_gone and right_arm_gone:
		holding = true
	if not stunned:
		flip_check()
		jumping(delta, height)
		moving(delta)
#	if not dead:
	the_movement(delta)
	animate()
	knockback()
	if effect != null:
		effect(delta)
#	update()
#########################

