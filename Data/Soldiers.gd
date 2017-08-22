extends "res://Data/Basic_infantry.gd"

func original_colour():
	hit = false
	arm_r.set_modulate(Color(1, 1, 1))
	head.set_modulate(Color(1, 1, 1))
	get_node("body/legs").set_modulate(Color(1, 1, 1))
	
func red():
	arm_r.set_modulate(Color(255,0, 0))
	head.set_modulate(Color(255,0, 0))
	get_node("body/legs").set_modulate(Color(255,0, 0))
	
func die(delta):
	deathTime -= delta
	if get_rotd() > -90 and get_rotd() < 90:  
		rotate(.05 * flip_mod)
		holding = true
	if deathTime <= 0:
		queue_free()
	
func health():
	var scale = 3
	if health > 0.0:
		get_node("body/head/health_meter/health").set_scale(Vector2(1, (health/total_health) * scale)) 
		if health/total_health > 0.25:
			get_node("body/head/health_meter/health").set_modulate(Color(0, 255, 0))
		elif health/total_health <= 0.25:
			get_node("body/head/health_meter/health").set_modulate(Color(255, 0, 0))
	else:
		get_node("body/head/health_meter/health").set_scale(Vector2(1, 0))
		get_node("body/head/health_meter/health").set_modulate(Color(255, 0, 0))

func death():
	faction.attacker_list.remove(faction.attacker_list.find(self))
	var hold_order = 1
	var hold_range = 30
	for allys in faction.attacker_list:
		allys.hold_range = hold_range * hold_order
		hold_order += 1
	get_node("body").set_layer_mask_bit(faction.sidenumber, false)
	dead = true
	if defending:
		objective.defenders.remove(objective.defenders.find(self))
		objective.occupency()
		objective.defend()
		
func defend():
	for building in faction.defence_list:
		if not building.full:
			objective = building
			orders("defend")
			building.defenders.append(self)
			building.occupency()

			break
			
func defending():
	holding = false
	if in_defence:
		holding = true
	elif abs(objective.get_global_pos().x - get_pos().x) <= 10:
		objective.place(self)
		velocity.x = 0
		in_defence = true
		holding = true
	else:
		raycast.set_rot(get_angle_to(objective.get_global_pos()) - 3.14159/2)

#func patrol():
#	patrol = true
#	var random = rand_range(1, -1)
#	var wait_time = rand_range(1, 5)
#	timer.set_wait_time(wait_time)
#	timer.start()

func prone(proned):
	if proned:
		get_node("body").set_pos(Vector2(0, 14))
		get_node("body/prone").set_trigger(false)
		get_node("body/standing").set_trigger(true)
		get_node("body/prone").set_pos(get_node("body/legs").get_pos())
	else:
		get_node("body").set_pos(Vector2(0, 0))
		get_node("body/standing").set_trigger(false)
		get_node("body/prone").set_trigger(true)
		get_node("body/standing").set_pos(get_node("body/legs").get_pos())
		
	if is_prone != true:
		head.set_pos(Vector2(0, -13))
		get_node("body/legs").set_pos(Vector2(0, 5))
		get_node("body/legs/secondaryEquip").set_pos(Vector2(-5, -20))
		arm_r.set_pos(Vector2(-5, -3))
		if headArmour != []:
			headArmour[0].set_pos(Vector2(0 , -4))
		if bodyArmour != []:
			bodyArmour[0].set_rotd(0)
			bodyArmour[0].set_pos(Vector2(0, -4))
		if secondaryGun != []:
			secondaryGun[0].set_pos(Vector2(get_node("body/legs/secondaryEquip").get_pos()))
			secondaryGun[0].set_rotd(-90)

	elif is_prone == true:
		get_node("body/legs").set_pos(Vector2(-4, -2))
		get_node("body/legs/secondaryEquip").set_pos(Vector2(14, - 2))
		head.set_pos(Vector2(12, -6))
		arm_r.set_pos(Vector2(-1, -1))
		if headArmour != []:
			headArmour[0].set_pos(Vector2(0, -4))
		if bodyArmour != []:
			bodyArmour[0].set_rotd(-90)
			bodyArmour[0].set_pos(Vector2(2, 0))
		if primaryGun != []:
			primaryGun[0].set_pos(get_node("body/arm_r/Gun").get_pos())
		if secondaryGun != []:
			secondaryGun[0].set_rotd(180)
			secondaryGun[0].set_pos(Vector2(get_node("body/legs/secondaryEquip").get_pos()))

	flip(flipped)
	
	