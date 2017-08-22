extends "res://Characters.gd"

var building = false
var repairing = false
var total_repair_check = 5
var repair_check = 5
var build_time = 1
var waiting = false
#
#func patrol():
#	patrol = true
#	random = rand_range(1, -1)
#	var wait_time = rand_range(1, 5)
#	timer.set_wait_time(wait_time)
#	timer.start()
	
func death():
	faction.builder_list.remove(faction.builder_list.find(self))
	var hold_order = 1
	var hold_range = 30
	for allys in faction.builder_list:
		allys.hold_range = hold_range * hold_order
		hold_order += 1
	get_node("body").set_layer_mask_bit(faction.sidenumber, false)
	dead = true
	if building:
		objective.builders.remove(objective.builders.find(self))
	elif repairing:
		objective.repair_list.remove(objective.repair_list.find(self))
	spawn_home.spawns.remove(spawn_home.spawns.find(self))
	
func build():
	for building in faction.build_list:
		if not building.full:
			orders("build")
			building.builders.append(self)
			building.occupency()
			objective = building
			break
	if building == false:
		repair()
		
func repair():
	for building in faction.defence_list:
		if not building.repair_full and not building.dead:
			if building.health < building.total_health:
				building.repair_list.append(self)
				orders("repair")
				objective = building
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
		go_to(objective)

func repairing(delta):
	holding = false
	if abs(objective.get_global_pos().x - get_pos().x) <= 10:
		objective.health += build_time * 10 * delta
		holding = true
		if objective.health >= objective.total_health:
			objective.health = objective.total_health
			objective.repair_list.remove(objective.repair_list.find(self))
			orders("waiting")
			repair()
	else:
		go_to(objective)
		
func waiting(delta):
	repair_check -= delta
	if repair_check <= 0:
		repair_check = total_repair_check
		repair()
	go_to(objective)
	
func runaway():
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