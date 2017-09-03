extends "res://Characters.gd"

var building = false
var repairing = false
var total_repair_check = 5
var repair_check = 5
var build_time = 1
var waiting = false

func track(collider):
	target_list.append(weakref(collider))
	
func untrack(collider):
	target_list.pop_front()
	
func death():
	dead = true
	faction.builder_list.remove(faction.builder_list.find(myself))
	get_node("body").set_layer_mask_bit(faction.sidenumber, false)
	if building:
		if !objective:
			pass
		else:
			objective.remove(self)
	if repairing:
		if !objective:
			pass
		else:
			objective.repair_list.remove(objective.repair_list.find(myself))
	if spawn_home != null:
		spawn_home.get_ref().spawns.remove(spawn_home.get_ref().spawns.find(myself))
	
func build():
	building = false
	for building in faction.build_list:
		if not building.get_ref().full and not building.get_ref().dead:
			building.get_ref().builders.append(myself)
			building.get_ref().occupency()
			objective = building.get_ref()
			orders("build")
			break
	if building == false:
		repair()
		
func repair():
	for building in faction.defence_list:
		if not building.get_ref().repair_full:
			if building.get_ref().health < building.get_ref().total_health:
				building.get_ref().repair_list.append(myself)
				objective = building.get_ref()
				orders("repair")
				break

	if repairing == false:
		orders("waiting")

func orders(commands):
	repair_check = total_repair_check
	repairing = false
	building = false
	waiting = false
	follow = false
	if commands == "build":
		building = true
	elif commands == "repair":
		repairing = true
	elif commands == "waiting":
		waiting = true
		if faction.side == "allies":
			for obj in level.objective_list:
				if obj.side == faction.side:
					objective = obj
		elif faction.side == "enemies":
			for obj in level.objective_list:
				if obj.side == faction.side:
					objective = obj
					break
	elif commands == "follow":
		follow = true
		
func building(delta):
	holding = false
	if abs(objective.get_global_pos().x - get_pos().x) <= 10:
		objective.build_time -= build_time * delta
		building = true
		holding = true
	else:
		if is_prone:
			prone(false)
		raycast.set_rot(get_angle_to(objective.get_global_pos()) - 3.14159/2)

func repairing(delta):
	holding = false
	if abs(objective.get_global_pos().x - get_pos().x) <= 10:
		objective.health += build_time * 10 * delta
		holding = true
		if objective.health >= objective.total_health:
			objective.health = objective.total_health
			objective.repair_list.remove(objective.repair_list.find(myself))
			repairing = false
			build()
	else:
		if is_prone:
			prone(false)
		raycast.set_rot(get_angle_to(objective.get_global_pos()) - 3.14159/2)

func waiting(delta):
	repair_check -= delta
	if repair_check <= 0:
		repair_check = total_repair_check
		build()
	go_to(objective)
	
func runaway():
	if !target_list.front().get_ref():
		target_list.pop_front()
	elif target_list.front().get_ref().get_parent().dead:
		target_list.pop_front()
	else:
		holding = false
		var flee
		if faction.side == "allies":
			if faction.side == "allies":
				for obj in level.objective_list:
					if obj.side == faction.side:
						flee = obj
						break
		elif faction.side == "enemies":
			for obj in level.objective_list:
				if obj.side == faction.side:
					flee = obj
		if flee == null:
			pass
		else:
			go_to(flee)
			if abs(get_global_pos().x) <= flee.get_global_pos().x:
				prone(true) 
				