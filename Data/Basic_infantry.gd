extends "res://Characters.gd"
var attacks = preload("res://Attacks.tscn")
var defending = false
var in_defence= false

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
						objective = obj
						break
			elif faction.side == "enemies":
				for obj in level.objective_list:
					if obj.side != faction.side:
						objective = obj
		elif commands == "hold":
			hold = true
		elif commands == "follow":
			follow = true
		elif commands == "retreat":
			retreat = true
			if faction.side == "allies":
				for obj in level.objective_list:
					if obj.side == faction.side:
						objective = obj
			elif faction.side == "enemies":
				for obj in level.objective_list:
					if obj.side == faction.side:
						objective = obj
						break

func melee():
	attack_ready = false
	melee = true
	fire_ready.stop()

#	var Aimrot = arm_r.get_rot() * flip_mod
#	var pos = Vector2(cos(Aimrot), -sin(Aimrot)) * flip_mod
	var spawn_point = arm_r.get_global_pos()
	var m = attacks.instance().get_node("Gun_melee").duplicate()
#	m.set_pos(spawn_point)
	m.attacker = self
	m.set_collision_mask_bit(faction.enemynumber, true)
#	m.enemyside = enemyside
	if primaryGun != []:
		m.damage = primaryGun[0].melee_damage
		fire_ready.set_wait_time(.5)
		m.stopping_power = primaryGun[0].melee_stopping_power + melee_stopping_power
	else:
		m.stopping_power = melee_stopping_power
		fire_ready.set_wait_time(.5)
	fire_ready.start()
	arm_r.add_child(m)
	armanim = "Melee"
	
func fire():
	attack_ready = false
	fire_ready.stop()
#	h.get_node("Player1").shoot(self)
	var Aimrot = arm_r.get_rot() * flip_mod
	var pos = Vector2(cos(Aimrot), -sin(Aimrot)) * flip_mod
	var spawn_point = pos + primaryGun[0].get_node("barrel_tip").get_global_pos()

	for bullets in range(primaryGun[0].bullets_inbullets):
		bullets = primaryGun[0].bullettype()
		if flip_mod == -1:
			bullets.get_node("Sprite").set_flip_h(true)  
			bullets.flip_mod = -1
		bullets.set_rotd(rad2deg(Aimrot) + rand_range(primaryGun[0].accuracy, -primaryGun[0].accuracy))
		bullets.set_collision_mask_bit(faction.enemynumber, true)
		bullets.set_pos(spawn_point)
		bullets.side = side
		level.add_child(bullets)
	primaryGun[0].shoot()
	armanim = "Shoot"
	fire_ready.set_wait_time(primaryGun[0].fire_rate)
	fire_ready.start()
	if primaryGun[0].current_clip <= 0 and primaryGun[0].current_ammo > 0:
		reload()
		
func dropGun():
	primaryGun[0].level.remove_child(primaryGun[0])
	fire_ready.stop()
	level.add_child(primaryGun[0])
	primaryGun[0].set_global_pos(get_node("body/arm_r/Gun").get_global_pos())
	primaryGun[0].unlock()
	primaryGun.remove(0)
	
		
func unequip(itemvar):
	itemvar[0].named = str(itemvar[0].name)
	itemvar[0].is_equipped = false
	itemvar[0].queue_free()
	itemvar.pop_front()

func equip(item, pickedup, slot):
	if pickedup == true:
		pack.append(item)
	if item.is_in_group("weapons") and slot == "primaryGun":
		if primaryGun != [] and secondaryGun != []:
			unequip(primaryGun)
			arm_r.add_child(item)
			primaryGun.append(item)
		elif primaryGun != [] and secondaryGun == []:
			primaryGun[0].level.remove_child(primaryGun[0])
			get_node("body/legs").add_child(primaryGun[0])
			arm_r.add_child(item)
			primaryGun.append(item)
			secondaryGun.append(primaryGun[0])
			primaryGun.pop_front()
		else:
			primaryGun.append(item)
			arm_r.add_child(item)
		if primaryGun != []:
			primaryGun[0].set_pos(get_node("body/arm_r/Gun").get_pos())
			primaryGun[0].set_rotd(get_node("body/arm_r/Gun").get_rotd())
		if secondaryGun != []:
			secondaryGun[0].set_pos(get_node("body/legs/secondaryEquip").get_pos())
			secondaryGun[0].set_rot(get_node("body/legs/secondaryEquip").get_rot())
	elif item.is_in_group("weapons") and slot == "secondaryGun":
		if secondaryGun != []:
			unequip(secondaryGun)
		secondaryGun.append(item)
		secondaryGun[0].set_pos(get_node("body/legs/secondaryEquip").get_pos())
		secondaryGun[0].set_rotd(get_node("body/legs/secondaryEquip").get_rotd())
		get_node("body/legs").add_child(secondaryGun[0])
	elif item.is_in_group("armour"):
		if item.is_in_group("head"):
			if headArmour != []:
				headArmour[0].level.remove_child(headArmour[0])
				headArmour[0].unequip(self)
				headArmour.pop_front()
			headArmour.append(item)
			get_node("body/Head").add_child(item)
			item.set_pos(Vector2(get_node("body/Head").get_pos().x, -4))
			item.set_rot(0)
			headArmour[0].equip(self)
		elif item.is_in_group("body"):
			if bodyArmour != []:
				bodyArmour[0].level.remove_child(bodyArmour[0])
				bodyArmour[0].unequip(self)
				bodyArmour.pop_front()
			bodyArmour.append(item)
			get_node("body/legs").add_child(item)
			item.set_pos(Vector2(get_node("body/legs").get_pos().x, -4))
			item.set_rot(get_node("body/legs").get_rot())
			item.set_rot(0)
			bodyArmour[0].equip(self)
			
func swap():
	if reloading == true:
		stop_reload()
	if primaryGun != [] and secondaryGun != []:
		secondaryGun.append(primaryGun[0])
		primaryGun.append(secondaryGun[0])
		secondaryGun.pop_front()
		primaryGun.pop_front()
	elif primaryGun == [] and secondaryGun !=[]:
		primaryGun.append(secondaryGun[0])
		secondaryGun.pop_front()
	elif primaryGun != [] and secondaryGun == []:
		secondaryGun.append(primaryGun[0])
		primaryGun.pop_front()
	if primaryGun != []:
		primaryGun[0].level.remove_child(primaryGun[0])
		primaryGun[0].set_pos(get_node("body/arm_r/Gun").get_pos())
		primaryGun[0].set_rotd(get_node("body/arm_r/Gun").get_rotd())
		get_node("body/arm_r").add_child(primaryGun[0])
	if secondaryGun != []:
		secondaryGun[0].level.remove_child(secondaryGun[0])
		secondaryGun[0].set_pos(get_node("body/legs/secondaryEquip").get_pos())
		secondaryGun[0].set_rotd(get_node("body/legs/secondaryEquip").get_rotd())
		get_node("body/legs").add_child(secondaryGun[0])
	
func fireready():
	melee = false
	if primaryGun != []:
		if reloading == true:
			reloading = false
			primaryGun[0].reload()
		attack_ready = true
		fire_ready.set_wait_time(primaryGun[0].fire_rate)
		fire_ready.start()
		
func stop_reload():
	reloading = false
	fire_ready.set_wait_time(primaryGun[0].reload_speed)
	fire_ready.set_wait_time(primaryGun[0].fire_rate)
	fire_ready.start()
	
func reload():
	reloading = true
	fire_ready.stop()
	fire_ready.set_wait_time(primaryGun[0].reload_speed)
	fire_ready.start()
	
func cast(collider):
#	print("working")
	if collider.get_parent().get_parent().side != faction.side:
#		print ("collider is in allies")
#		target_list.append(collider)
		track(collider)
#		var position = Vector2(Collider.get_global_pos().x, Collider.get_global_pos().y - Collider.get_global_pos().y)
#		print (collider.get_name())
#		raycast.set_cast_to(position)
#		print("casting")
#		collider = Collider
#		raycast.add_exception(collider)
#		cast = true
#		print (raycast.get_cast_to())
#		if raycast.is_colliding():
#			print ("colliding")
#			print (raycast.get_collider())
#			if raycast.get_collider().is_in_group("players") or raycast.get_collider().is_in_group("allies"):
#				target_list.append(collider)
#				print(target_list)
				
#		player = collider
		
func track(collider):
#	raycast.add_exception(collider)
	if collider in target_list:
		pass
	else:
		target_list.append(collider)



func untrack(collider):
	if collider.get_parent().get_parent().side != faction.side:
		if collider in target_list:
			target_list.remove(target_list.find(collider))