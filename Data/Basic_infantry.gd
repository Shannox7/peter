extends "res://Characters.gd"
var attacks = preload("res://Attacks.tscn")
var bomb_time = 3
var total_bomb_time = 3
var bomb_damage = 25
var objective_pos = Vector2()

func check_null(ref):
	if !ref.get_ref():
		return true
	elif ref == null:
		return true
	elif ref.get_ref().dead:
		return true
	else:
		return false

func orders(commands):
	attack = false
	follow = false
	hold = false
	retreat = false
	if patrol:
		WALK_SPEED += patrol_speed
		patrol = false
	occupy = false
	defending = false
	investigate = false
	if commands == "chase":
		chase = true
	elif not chase:
		if commands == "attack":
			attack = true
#			if faction.side == "allies":
#				for obj in level.objective_list:
#					if obj.get_ref().side != faction.side:
#						objective = obj.get_ref().positions[obj.get_ref().positions.size() - 1]
#						break
#			elif faction.side == "enemies":
#				for obj in level.objective_list:
#					if obj.get_ref().side != faction.side:
#						objective = obj.get_ref().positions[0]
		elif commands == "defend":
			defending = true
			if faction.defence_list == []:
				orders("patrol")
			elif !faction.defence_list.front().get_ref():
				pop_front()
				orders("defend")
			else:
				objective = faction.defence_list.front()
				for building in faction.defence_list:
					if !building.get_ref():
						pass
					if building.get_ref().wall:
						objective = building
			job = "Defending Wall"
		elif commands == "investigate":
			investigate = true
		elif commands == "hold":
			hold = true
		elif commands == "follow":
			follow = true
		elif commands == "patrol":
			WALK_SPEED -= patrol_speed
			patrol_time = 0
			patrol = true
		elif commands == "occupy":
			occupy = true
		elif commands == "retreat":
			retreat = true
			if faction.side == "allies":
				for obj in level.objective_list:
					if obj.get_ref().side == faction.side:
						objective = obj.get_ref().positions[0]
			elif faction.side == "enemies":
				for obj in level.objective_list:
					if obj.get_ref().side == faction.side:
						objective = obj.get_ref().positions[obj.get_ref().positions.size() - 1]
						break

func blowup_building(delta):
	holding = false
	var target = building_list.front()
	if !target.get_ref():
		building_list.pop_front()
	elif target.get_ref().dead:
		building_list.pop_front()
	else:
		var targeting = target.get_ref().get_node("body")
#		look(target)
		raycast.set_rot(get_angle_to(targeting.get_global_pos()) - 3.14159/2)
		if abs(get_global_pos().x - targeting.get_global_pos().x) <= 30:
			holding = true
			bomb_time -= delta
			if bomb_time <= 0:
				bomb_time = total_bomb_time
				targeting.get_parent().health -= bomb_damage
				if targeting.get_parent().health <= 0:
					targeting.get_parent().death()
		else:
			bomb_time = total_bomb_time
			
			
					
	
#func die(delta):
#	deathTime -= delta
#	if get_rotd() > -90 and get_rotd() < 90:  
#		rotate(.05 * flip_mod)
#		holding = true
#	if deathTime <= 0:
#	call_deferred("queue_free")

func check_injure():
	if health <= 0:
		injure()
	health()

func injure():
	injured = true
	if building != null:
		if !building.get_ref():
			pass
		elif not building.get_ref().dead:
			building.get_ref().remove_occupent(building.get_ref().occupents.find(myself))
	job = "Injured"
#	faction.attacker_list.remove(faction.attacker_list.find(myself))
	get_node("body").set_layer_mask_bit(faction.sidenumber, false)

func injured(delta):
#	deathTime -= delta
	if get_rotd() > -90 and get_rotd() < 90:  
		rotate(.05 * flip_mod)
		holding = true
	else:
		set_rotd(90 * flip_mod)
#		set_fixed_process(false)
#	if deathTime <= 0:
#		call_deferred("queue_free")
func heal():
	set_rotd(0)
	set_layer_mask_bit(faction.sidenumber, true)
	health = total_health
	set_fixed_process(true)
	
func health():
	var head_health = get_node("body/head/head/health_meter/health")
	var scale = 3
	if health > 0.0:
		head_health.set_scale(Vector2(1, (health/total_health) * scale)) 
		if health/total_health > 0.25:
			head_health.set_modulate(Color(0, 255, 0))
		elif health/total_health <= 0.25:
			head_health.set_modulate(Color(255, 0, 0))
	else:
		head_health.set_scale(Vector2(1, 0))
		head_health.set_modulate(Color(255, 0, 0))
		
func zombified():
	pass
	
func die_on_mission():
	if occupy:
		if !objective.get_ref():
			pass
		elif not objective.get_ref().dead:
			objective.get_ref().remove_occupent(objective.get_ref().occupents.find(myself))
	faction.attacker_list.remove(faction.attacker_list.find(myself))
	call_deferred("queue_free")
	
func death():
	dead = true
	if building != null:
		if !building.get_ref():
			pass
		elif not building.get_ref().dead:
			building.get_ref().remove_occupent(building.get_ref().occupents.find(myself))
	get_node("body").set_layer_mask_bit(faction.sidenumber, false)
	get_node("SamplePlayer2D").play("death")
		
func defend():
	for vehicle in faction.vehicle_list:
		if !vehicle.get_ref():
			pass
		elif not vehicle.get_ref().full and not vehicle.get_ref().dead:
			objective = vehicle.get_ref().myself
			orders("defend")
			vehicle.get_ref().add_operator(self)
			break
	if not defending:
		for building in faction.defence_list:
			if !building.get_ref():
				pass
			elif not building.get_ref().full:
				objective = building.get_ref().myself
				orders("defend")
				building.get_ref().add_operator(self)
				break
			
func defending():
#	print("defending")
	holding = false
	var obj = Vector2(objective.get_ref().get_global_pos().x - (hold_order * 10),0)
	if !objective.get_ref():
		orders("defend")
	elif objective.get_ref().dead:
		orders("defend")
	elif get_global_pos().distance_to(obj) <= 30 and get_global_pos().x < obj.x:
		raycast.set_rotd(90)
#		flip(false)
#		primaryGun[0].aiming(false, faction.enemynumberval)
#		objective.get_ref().call_deferred("place", self)
#		objective.get_ref().call_deferred("place", self)
#		placed = true
		holding = true
	else:
		raycast.set_rot(get_angle_to(obj) - 3.14159/2)

func placing():
	holding = false
	if !objective.get_ref():
		orders("patrol")
	elif get_pos().distance_to(objective.get_ref().get_global_pos()) <= 30:
		primaryGun[0].aiming(false, faction.enemynumberval)
		objective.get_ref().call_deferred("place", self)
		placed = true
		holding = true
	else:
		raycast.set_rot(get_angle_to(objective.get_ref().get_global_pos()) - 3.14159/2)
	

func original_colour():
	hit = false
#	if effect == null:
#		arm_r.get_node("bicep").set_modulate(Color(1,1, 1))
#		arm_r.get_node("bicep/forearm").set_modulate(Color(1,1, 1))
#		arm_r.get_node("bicep/forearm/hand").set_modulate(Color(1,1, 1))
#		arm_l.get_node("bicep").set_modulate(Color(1,1, 1))
#		arm_l.get_node("bicep/forearm").set_modulate(Color(1,1, 1))
#		arm_l.get_node("bicep/forearm/hand").set_modulate(Color(1,1, 1))
#		for limb in leg_l.get_children():
#			limb.set_modulate(Color(1,1, 1))
#		for limb in leg_r.get_children():
#			limb.set_modulate(Color(1,1, 1))
#		head.set_modulate(Color(1,1, 1))
#		legs.set_modulate(Color(1,1, 1))
#		waist.set_modulate(Color(1,1, 1))
	
func burning():
	arm_r.get_node("bicep").set_modulate(Color(0,0, 0))
	arm_r.get_node("bicep/forearm").set_modulate(Color(0,0, 0))
	arm_r.get_node("bicep/forearm/hand").set_modulate(Color(0,0, 0))
	arm_l.get_node("bicep").set_modulate(Color(0,0, 0))
	arm_l.get_node("bicep/forearm").set_modulate(Color(0,0, 0))
	arm_l.get_node("bicep/forearm/hand").set_modulate(Color(0,0, 0))
	for limb in leg_l.get_children():
		limb.set_modulate(Color(0,0, 0))
	for limb in leg_r.get_children():
		limb.set_modulate(Color(0,0, 0))
	head.set_modulate(Color(0,0, 0))
	legs.set_modulate(Color(0,0, 0))
	waist.set_modulate(Color(0,0, 0))

func shocking():
	arm_r.get_node("bicep").set_modulate(Color(5,5, 5))
	arm_r.get_node("bicep/forearm").set_modulate(Color(5,5, 5))
	arm_r.get_node("bicep/forearm/hand").set_modulate(Color(5,5, 5))
	arm_l.get_node("bicep").set_modulate(Color(5,5, 5))
	arm_l.get_node("bicep/forearm").set_modulate(Color(5,5, 5))
	arm_l.get_node("bicep/forearm/hand").set_modulate(Color(5,5, 5))
	for limb in leg_l.get_children():
		limb.set_modulate(Color(5,5, 5))
	for limb in leg_r.get_children():
		limb.set_modulate(Color(5,5, 5))
	head.set_modulate(Color(5,5, 5))
	legs.set_modulate(Color(5,5, 5))
	waist.set_modulate(Color(5,5, 5))

func blue():
#	get_node("hit_timer").start()
	arm_r.get_node("bicep").set_modulate(Color(0,0, 255))
	arm_r.get_node("bicep/forearm").set_modulate(Color(0,0, 255))
	arm_r.get_node("bicep/forearm/hand").set_modulate(Color(0,0, 255))
	arm_l.get_node("bicep").set_modulate(Color(0,0, 255))
	arm_l.get_node("bicep/forearm").set_modulate(Color(0,0, 255))
	arm_l.get_node("bicep/forearm/hand").set_modulate(Color(0,0, 255))
	for limb in leg_l.get_children():
		limb.set_modulate(Color(0,0, 255))
	for limb in leg_r.get_children():
		limb.set_modulate(Color(0,0, 255))
	head.set_modulate(Color(0,0, 255))
	legs.set_modulate(Color(0,0, 255))
	waist.set_modulate(Color(0,0, 255))
	
func red():
	get_node("hit_timer").start()
#	if effect == null:
#		arm_r.get_node("bicep").set_modulate(Color(255,0, 0))
#		arm_r.get_node("bicep/forearm").set_modulate(Color(255,0, 0))
#		arm_r.get_node("bicep/forearm/hand").set_modulate(Color(255,0, 0))
#		arm_l.get_node("bicep").set_modulate(Color(255,0, 0))
#		arm_l.get_node("bicep/forearm").set_modulate(Color(255,0, 0))
#		arm_l.get_node("bicep/forearm/hand").set_modulate(Color(255,0, 0))
#		for limb in leg_l.get_children():
#			limb.set_modulate(Color(255,0, 0))
#		for limb in leg_r.get_children():
#			limb.set_modulate(Color(255,0, 0))
#		head.set_modulate(Color(255,0, 0))
#		legs.set_modulate(Color(255,0, 0))
#		waist.set_modulate(Color(255,0, 0))
		
		
		