extends "res://Data/Npc/Army/Manned_turrets.gd"


func _fixed_process(delta):
	if target_list != []:
#		track_closest(target_list)
		one_way_target()
