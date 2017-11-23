extends "res://Data/Enemy.gd"



func _ready():
	faction = get_parent()
	level = get_parent().get_parent()
	side()
	if not spawned:
		WALK_SPEED = 100.0
		WALK_SPEED_TOTAL = 100.0
		spawned = true
		myself = weakref(self)
		enemy = true
		faction.attacker_list.append(myself)
		set_fixed_process(true)
		look = get_node("body/cast")
		jump_over = get_node("body/jump_over")
		jump_l = get_node("jump_l")
		jump_r = get_node("jump_r")
		arm_r = get_node("body/arm_r")
		arm_l = get_node("body/arm_l")
		head = get_node("body/head")
#		torso = get_node("body/torso")
		leg_l= get_node("body/leg_l")
		leg_r= get_node("body/leg_r")
		legs = get_node("body/legs")
		waist = get_node("body/waist")
		raycast = get_node("RayCast2D")
	#	rayNode = get_node("body/head/cast")
		fire_ready = get_node("body/Attack")
		fire_ready.set_wait_time(.5)
		fire_ready.connect("timeout", self, "fireready")
		get_node("hit_timer").connect("timeout", self, "original_colour")
		get_node("body/Area2D").connect("body_enter", self, "track")
#		get_node("body/Area2D").connect("body_exit", self, "untrack")
		health_display = get_node("body/head/head/health_meter/health")
		armanimNode = get_node("AnimationPlayer")
		animNode = get_node("body/legs")
		health = total_health
		if random > 2:
			var basic_gun = guns.instance().get_node("Soldier_guns/AK47").duplicate()
			equip(basic_gun, false, "primaryGun")
		health()
		orders("patrol")

	

	
func chase():
	if chase == false:
		chase = true
	if not scream:
		get_node("AnimationPlayer").play("scream")
		get_node("SamplePlayer2D").play("scream")
		scream = true
		scream_delay = total_scream_delay

	
func _fixed_process(delta):
	reset()
	gravity_check(delta)
	grounded_check()
	if primaryGun != [] and target_list == [] and low_priority_list == [] or (primaryGun != [] and dead):
		primaryGun[0].aiming(false, faction.enemynumberval)
	
	if dead == true:
		die(delta)
	elif stunned:
		pass
	elif wait:
		holding = true
		wait(delta)
	elif retreat:
		go_to(objective)
		
	elif scream:
		scream(delta)
	elif target_list != [] and not stunned:
		var casting = target_list.front().get_ref().get_node("body").get_global_pos() - get_node("body").get_global_pos()
		look.set_cast_to(Vector2(casting.x * flip_mod, casting.y))
		if look.is_colliding():
			if look.get_collider() == null:
				pass
			elif look.get_collider().is_in_group("players") and not chase:
				chase()
			elif chase == true:
				scream_delay -= delta
				if scream_delay <= 0:
					get_node("AnimationPlayer").play("scream")
					get_node("SamplePlayer2D").play("scream")
					scream = true
					scream_delay = total_scream_delay
				attack(target_list)
				if target_list == []:
					chase = false
				elif target_list.front().get_ref().zone != zone and not moving:
					var goal = target_list.front().get_ref().zone.get_node("enters").get_children().front()
					for point in target_list.front().get_ref().zone.get_node("enters").get_children():
						if get_global_pos().distance_to(point.get_global_pos()) < get_global_pos().distance_to(goal.get_global_pos()):
							goal = point
					raycast.set_rot(get_angle_to(target_list.front().get_ref().zone.get_global_pos()) - 3.14159/2)
					call_deferred('navigate', goal)
				else:
					if target_list.front().get_ref().grounded and not moving:
						call_deferred('navigate', target_list.front().get_ref().get_node("body"))
			
		wait_time -= delta
		if wait_time <= 0:
			track_closest(target_list)
			wait_time = wait_time_total
	if attack:
		go_to(objective)
	if patrol and not chase:
		patrol(delta)

		
	if not stunned:
		if climbing:
			climbing()
		elif dropping:
			dropping()
		flip_check()
		moving(delta)
		if (not jump_l.is_colliding() or not jump_r.is_colliding()) and grounded and not climbing and not dropping:
			Jump()
			if (jump_press < 0.35):
				jump_press += delta
				velocity.y -= JUMP_FORCE * 2 * delta
			else:
				jumping = false
		if not dropping and not climbing and not ladder and not dead:
			jumping(delta)
		if not dead:
			the_movement(delta)
			
		if abs(velocity.x) > 5 and not holding and grounded and not is_prone:
			if not get_node("move").is_playing():
				get_node("move").play("run")
		elif not is_prone:
			get_node("move").play("idle")
		
		if abs(velocity.x) > 5 and not holding and grounded and is_prone:
			if not get_node("move").is_playing():
				get_node("move").play("prone_crawl")
		elif is_prone:
			get_node("move").play("prone_idle")
	elif is_prone:
		get_node("move").play("prone_idle")
	else:
		get_node("move").play("idle")
	knockback()
#	animation()

	if effect != null:
		effect(delta)