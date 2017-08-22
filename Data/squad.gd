extends Node2D
var Gunner = []
var Medic = []
var Leader = []
var Assault = []
var Sniper = []
var squad_list = []
var HQ
var objective_list = []
var a = preload("res://Allies.tscn")

func _ready():
	set_fixed_process(true)
	HQ = get_parent().get_node("allyGoal")
	squad_list = [Sniper,Medic,Leader,Gunner,Assault]
	objective_list = get_parent().objective_list
	
func spawn_squad():
	for ally in range(0, 5):
		if Gunner == []:
			var allies = a.instance().get_node("Movement").duplicate()
			allies.set_pos(HQ.get_pos())
			add_child(allies)
		elif Medic == []:
			var allies = a.instance().get_node("Movement").duplicate()
			allies.set_pos(HQ.get_pos())
			add_child(allies)
		elif Leader == []:
			var allies = a.instance().get_node("Movement").duplicate()
			allies.set_pos(HQ.get_pos())
			add_child(allies)
		elif Gunner == []:
			var allies = a.instance().get_node("Movement").duplicate()
			allies.set_pos(HQ.get_pos())
			add_child(allies)
		elif Assault == []:
			var allies = a.instance().get_node("Movement").duplicate()
			allies.set_pos(HQ.get_pos())
			add_child(allies)
func _fixed_process(delta):
	for lists in squad_list:
		for allies in lists:
			allies.objective