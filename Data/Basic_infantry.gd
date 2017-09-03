extends "res://Characters.gd"
var attacks = preload("res://Attacks.tscn")
var in_defence= false
var bomb_time = 3
var total_bomb_time = 3
var bomb_damage = 25

func orders(commands):
	attack = false
	follow = false
	hold = false
	retreat = false
	if commands == "defend":
		defending = true
	if not defending:
		if commands == "attack":
			attack = true
			if faction.side == "allies":
				for obj in level.objective_list:
					if obj.side != faction.side:
						objective = obj.positions[obj.positions.size() - 1]
						break
			elif faction.side == "enemies":
				for obj in level.objective_list:
					if obj.side != faction.side:
						objective = obj.positions[0]
		elif commands == "hold":
			hold = true
		elif commands == "follow":
			follow = true
		elif commands == "retreat":
			retreat = true
			if faction.side == "allies":
				for obj in level.objective_list:
					if obj.side == faction.side:
						objective = obj.positions[0]
			elif faction.side == "enemies":
				for obj in level.objective_list:
					if obj.side == faction.side:
						objective = obj.positions[obj.positions.size() - 1]
						break

func blowup_building(delta):
	holding = false
	var target = building_list.front()
	if !target.get_ref():
		untrack(target.get_ref().get_node("body"))
	elif target.get_ref().dead:
		untrack(target.get_ref().get_node("body"))
	else:
		var targeting = target.get_ref().get_node("body")
#		look(target)
		raycast.set_rot(get_angle_to(targeting.get_global_pos()) - 3.14159/2)
		if get_pos().distance_to(targeting.get_global_pos()) <= 30:
			holding = true
			bomb_time -= delta
			if bomb_time <= 0:
				bomb_time = total_bomb_time
				targeting.get_parent().health -= bomb_damage
				if targeting.get_parent().health <= 0:
					targeting.get_parent().death()
		else:
			bomb_time = total_bomb_time
			
			
					
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
		call_deferred("queue_free")
	
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
	var hold_order = 1
	var hold_range = 30

	get_node("body").set_layer_mask_bit(faction.sidenumber, false)
	if defending and not objective.dead:
		objective.op_dead(self)
	faction.attacker_list.remove(faction.attacker_list.find(myself))
#	for allys in faction.attacker_list:
#		allys.hold_range = hold_range * hold_order
#		hold_order += 1
		
func defend():
	for vehicle in faction.vehicle_list:
		if !vehicle.get_ref():
			pass
		elif not vehicle.get_ref().full and not vehicle.get_ref().dead:
			objective = vehicle.get_ref()
			orders("defend")
			vehicle.call_deferred("add_operator", self)
			break
	if not defending:
		for building in faction.defence_list:
			if !building.get_ref():
				pass
			elif not building.get_ref().full:
				objective = building.get_ref()
				orders("defend")
				building.get_ref().add_operator(self)
				break
			
func defending():
	holding = false
	if get_pos().distance_to(objective.get_global_pos()) <= 10:
		objective.call_deferred("place", self)
		in_defence = true
		holding = true
	else:
		raycast.set_rot(get_angle_to(objective.get_global_pos()) - 3.14159/2)

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