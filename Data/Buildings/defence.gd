extends "res://Data/Buildings/buildings.gd"
var defenders = []
var defender_size = 1
var frontorback = 9

var foreground = true
var background = false
func activate():
	set_z(-1)
	full = false
	level = get_parent().get_parent()
	faction = get_parent()
	set_layer_mask_bit(frontorback, true)
	faction.defence_list.append(self)
	set_layer_mask_bit(faction.sidenumber, true)
	set_layer_mask_bit(faction.enemynumber, true)
	set_collision_mask(faction.enemynumber)
	defend()


func occupency():
	if defenders.size() == defender_size:
		full = true
	else:
		full = false
		
func defend():
	if not full:
		for npc in faction.attacker_list:
			if not npc.defending and not full:
				npc.objective = self
				npc.orders("defend")
				defenders.append(npc)
				occupency()
				
func death():
	dead = true
	if defenders != []:
		for npc in defenders:
			npc.defending = false
			npc.hold_order("add")
			npc.orders(str(npc.player.standingorders))
	for builders in repair_list:
		builders.orders("waiting")
		builders.build()
	faction.defence_list.remove(faction.defence_list.find(self))
	queue_free()
	
