extends Node2D
var attending = false
var occupents = []
var occupency = 3
var party = []
var difficulty = 30

var food = 5
var scrap = 0
var medicine = 5

var fight = 0
var job = "Supply Run"

var myself

var name = "Bad Haircut"

var completed = false
var completion_time = 0

var Global
func _ready():
	Global = get_node("/root/Global")
	occupency()
	myself = weakref(self)
	
func remove_occupent(slot):
	if occupents[slot] == null:
		pass
	elif !occupents[slot].get_ref():
		occupents[slot] = null
#	elif occupents[slot].get_ref().get_parent() == get_node("body"):
#		occupents[slot].get_ref().swap()
#		occupents[slot].get_ref().get_parent().remove_child(occupents[slot].get_ref())
#		occupents[slot].get_ref().defending = false
#		occupents[slot].get_ref().in_defence = false
#		faction.add_child(occupents[slot].get_ref())
#		occupents[slot].get_ref().set_global_pos(get_node("body/defence_pos").get_global_pos())
#		occupents[slot].get_ref().set_fixed_process(true)
#		occupents[slot].get_ref().flip(flipped)
	else:
		if occupents[slot].get_ref().AI: 
			occupents[slot].get_ref().defending = false
			occupents[slot].get_ref().orders("patrol")
			occupents[slot].get_ref().set_fixed_process(true)
			
	occupents[slot].get_ref().placed = false
	occupents[slot].get_ref().building = null
	occupents[slot].get_ref().job = ''
	occupents[slot].get_ref().objective = null
	occupents[slot] = null

func occupy(npc, slot):
	npc.building = myself
	occupents[slot] = npc.myself
	npc.objective = myself
	if npc.AI:
		npc.orders("patrol")
	occupents[slot].get_ref().job = self.job
	pass

func occupency():
	for number in range(occupency):
		occupents.append(null)
	pass

func place(npc):
	pass
#func place(npc):
#	npc.set_global_pos(get_global_pos())
#	npc.set_fixed_process(false)
	
func level():
	return Global.generate_level("res://Zombies711.tscn")
	Global.running_events.append(self)


func mission_details():
	print("army!")
	pass