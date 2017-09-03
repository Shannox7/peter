extends "res://Data/Buildings/buildings.gd"
var operators = []
var operators_size = 1
var frontorback = 9
var foreground = true
var background = false
var operator

func initialize():
	set_z(-1)
	full = false
	level = get_parent().get_parent()
	faction = get_parent()
	get_node("KinematicBody2D").set_layer_mask_bit(frontorback, true)
	myself = weakref(self)
	faction.defence_list.append(myself)
	get_node("KinematicBody2D").set_layer_mask_bit(faction.sidenumber, true)
#	set_layer_mask_bit(faction.enemynumber, true)
#	set_collision_mask(faction.enemynumber)
#	defend()
		
	
func occupency():
	if operators.size() == operators_size:
		full = true
	else:
		full = false

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
				
func death():
	faction.defence_list.remove(faction.defence_list.find(myself))
	for npc in operators:
		if npc == null:
			pass
		elif operators[0] == npc.get_ref().myself:
			if npc.get_ref().get_parent() == get_node("KinematicBody2D"):
				npc.get_ref().swap()
				npc.get_ref().get_parent().remove_child(npc.get_ref())
#					npc.hold_order("add")
				npc.get_ref().defending = false
				npc.get_ref().in_defence = false
				faction.add_child(npc.get_ref())
				npc.get_ref().set_global_pos(get_node("KinematicBody2D/defence_pos").get_global_pos())
				npc.get_ref().set_fixed_process(true)
				npc.get_ref().flip(true)
				
			else:
				npc.get_ref().defending = false
				npc.get_ref().orders("attack")
	for builders in repair_list:
		if not builders.get_ref().dead:
#			builders.orders("waiting")
			builders.get_ref().build()
	if faction.AI:
		faction.player_list[0].bunkers -= 1
	call_deferred("remove_positioning")
	call_deferred("queue_free")
	
