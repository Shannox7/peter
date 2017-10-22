extends "res://Data/Buildings/buildings.gd"
var operators = []
var operators_size = 1
var frontorback = 9
var foreground = true
var background = false
var operator
var job = "Defending"
func initialize():
	occupency()
	full = false
	level = get_parent().get_parent()
	faction = get_parent()
	get_node("body").set_layer_mask_bit(frontorback, true)
	myself = weakref(self)
	faction.defence_list.append(myself)
	get_node("body").set_layer_mask_bit(faction.sidenumber, true)
#	set_layer_mask_bit(faction.enemynumber, true)
#	set_collision_mask(faction.enemynumber)
#	defend()
		
	
#func occupency():
#	if operators.size() == operators_size:
#		full = true
#	else:
#		full = false

func deactivate():
	pass
		
func defend():
	if not full:
		for npc in faction.attacker_list:
			if not npc.defending and not full:
				npc.objective = self
				npc.orders("defend")
				operators.append(npc)
				occupency()
				
func remove_occupent(slot):
	if occupents[slot] == null:
		pass
	elif !occupents[slot].get_ref():
		occupents[slot] = null
	elif occupents[slot].get_ref().get_parent() == get_node("body"):
		occupents[slot].get_ref().swap()
		occupents[slot].get_ref().get_parent().remove_child(occupents[slot].get_ref())
		occupents[slot].get_ref().defending = false
		occupents[slot].get_ref().placed = false
		faction.add_child(occupents[slot].get_ref())
		occupents[slot].get_ref().set_global_pos(get_node("body/defence_pos").get_global_pos())
		occupents[slot].get_ref().set_fixed_process(true)
		occupents[slot].get_ref().flip(flipped)
		if slot == 0:
			get_node("body/machinegun_turret").call_deferred("deactivate")
	else:
		occupents[slot].get_ref().defending = false
		occupents[slot].get_ref().set_fixed_process(true)
		
	occupents[slot].get_ref().building = null
	occupents[slot].get_ref().job = ''
	occupents[slot].get_ref().objective = null
	occupents[slot].get_ref().orders("patrol")
	occupents[slot] = null
func death():
	faction.defence_list.remove(faction.defence_list.find(myself))
	for npc in operators:
		if npc == null:
			pass
		elif !npc.get_ref():
			pass
		elif operators[0] == npc.get_ref().myself:
			if npc.get_ref().get_parent() == get_node("body"):
				npc.get_ref().swap()
				npc.get_ref().get_parent().remove_child(npc.get_ref())
#					npc.hold_order("add")
				npc.get_ref().defending = false
				npc.get_ref().placed = false
				faction.add_child(npc.get_ref())
				npc.get_ref().set_global_pos(get_node("body/defence_pos").get_global_pos())
				npc.get_ref().set_fixed_process(true)
				npc.get_ref().flip(flipped)
				
			else:
				npc.get_ref().defending = false
				npc.get_ref().orders("attack")
	for builders in repair_list:
		if !builders.get_ref():
			pass
		elif not builders.get_ref().dead:
			builders.get_ref().build()
	if faction.AI and not manual_placed:
		AI_recount(faction.player_list[0])
	call_deferred("remove_positioning")
	call_deferred("queue_free")
	
