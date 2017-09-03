extends "res://Characters.gd"
var repair_list = []
var vehicle = true
var operators = []
var full = false
var operator
var Gun

func track(collider):
	if collider.get_parent().myself in target_list or collider.get_parent().myself in building_list or collider.get_parent().myself in low_priority_list:
		pass
	elif collider.get_parent().has_method("initialize"):
		if collider.get_parent().background == true:
			building_list.append(collider.get_parent().myself)
		else:
			target_list.append(collider.get_parent().myself)
	elif collider.get_parent().has_method("repairing"):
		low_priority_list.append(collider.get_parent().myself)
	else:
		target_list.append(collider.get_parent().myself)
		
func untrack(collider):
	if collider.get_parent().myself in target_list:
		target_list.remove(target_list.find(collider.get_parent().myself))
	elif collider.get_parent().myself in building_list:
		building_list.remove(building_list.find(collider.get_parent().myself))
	elif collider.get_parent().myself in low_priority_list:
		low_priority_list.remove(low_priority_list.find(collider.get_parent().myself))

func go_to(object):
	holding = false
	if object == null:
		holding = true
	else:
		raycast.set_rot(get_angle_to(object.get_global_pos()) - 3.14159/2)
		if abs(object.get_global_pos().x - get_pos().x) <= 10:
			holding = true

#func attack():
#	var Aimrot = Gun.get_rot() * flip_mod
#	var pos = Vector2(cos(Aimrot), -sin(Aimrot)) * flip_mod
#	var spawn_point = pos + Gun.get_node("barrel_tip").get_global_pos()
#	for bullets in range(Gun.bullets_inbullets):
#		bullets = Gun.bullettype()
#		if flip_mod == -1:
#			bullets.get_node("Sprite").set_flip_h(true)  
#			bullets.flip_mod = -1
#		bullets.set_rotd(rad2deg(Aimrot) + rand_range(Gun.accuracy, -Gun.accuracy))
#		bullets.set_collision_mask_bit(faction.enemynumber, true)
#		bullets.set_pos(spawn_point)
#		bullets.side = faction.side
#		level.add_child(bullets)
#
#	Gun.shoot()
#	attack_ready = false
#	if Gun.current_clip <= 0 and Gun.current_ammo > 0:
#		reload()
		
func orders(commands):
	attack = false
	hold = false
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

func flip_check():
	if raycast.get_rotd() < -90  and flipped == false:
		flipped = true
		flip(true)
	elif raycast.get_rotd() > -90 and flipped == true:
		flipped = false
		flip(false)

		
func death():
	dead = true
	for npc in operators:
		if npc != null:
			if not npc.dead and npc.get_parent() == get_node("body"):
				npc.get_parent().remove_child(npc)
				npc.defending = false
				npc.in_defence = false
				faction.add_child(npc)
				if npc == operators[0]:
					npc.set_global_pos(get_node("body/driver_pos").get_global_pos())
				elif npc == operators[1]:
					npc.set_global_pos(get_node("body/gunner_pos").get_global_pos())
				npc.swap()
				npc.hold_order("add")
				npc.set_fixed_process(true)
				npc.flip(true)
			else:
				npc.defending = false
				npc.orders("attack")
	for builders in repair_list:
		if not builders.dead:
			builders.orders("waiting")
			builders.build()
	faction.vehicle_list.remove(faction.vehicle_list.find(self))
	if spawn_home != null:
		spawn_home.spawns.remove(spawn_home.spawns.find(self))
	call_deferred("queue_free")
	
func tank_attack(target):
	target = target.get_ref()
	if !target:
		untrack(target.get_node("body"))
	elif target.dead:
		untrack(target.get_node("body"))
	else:
		var targeting = (target.get_node("body").get_global_pos())
		if rad2deg(get_node("body/turret_pos").get_angle_to(targeting) - 3.14159/2) <= 45 and rad2deg(get_node("body/turret_pos").get_angle_to(targeting) - 3.14159/2) >= -45:
			Gun.set_rot(get_node("body/turret_pos").get_angle_to(targeting)- 3.14159/2)
			operator.head.set_rot(Gun.get_rot())
			if get_global_pos().distance_to(targeting) <= (Gun.bulletspeed * Gun.distance) * .95:
				holding = true
				if attack_ready == true and Gun.current_clip > 0: 
					fire()
		else:
			Gun.set_rotd(0)
			operator.head.set_rotd(0)
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
