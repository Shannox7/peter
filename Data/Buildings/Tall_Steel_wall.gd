extends "res://Data/Buildings/Barricades.gd"
var name = "Tall Steel Wall"
var scrap_cost = 10
var food_cost = 0

var build_time = 5
var size = 1
#func initialize():
#	set_z(-1)
#	level = get_parent().get_parent()
#	faction = get_parent()
#	get_node("KinematicBody2D").set_layer_mask_bit(frontorback, true)
#	faction.defence_list.append(self)
#	get_node("KinematicBody2D").set_layer_mask_bit(faction.sidenumber, true)

#func AI_recount(AI):
#	AI.walls -= 1
	
func place(npc):
#	npc.animNode.play("idle")
	npc.placed = true
	npc.set_global_pos(defence_pos[occupents.find(npc.myself)].get_global_pos())
	npc.flip(false)
#	npc.set_fixed_process(false)
	
func _ready():
#	occupency = 5
	wall = true
	full = true
	total_health = 500
	health = total_health

func builder():
	return builder.get_node("two_tile_y/Build")

func red():
	get_node("body 1").set_modulate(Color(255, 1, 1))
func original_colour():
	get_node("body 1").set_modulate(Color(1, 1, 1))



