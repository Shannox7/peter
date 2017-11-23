extends "res://Data/Buildings/Resource.gd"
var name = "Farm"
var scrap_cost = 10
var food_cost = 5

var build_time = 4
var harvest_time = 5
var total_harvest_time = 5
var size = 4
var food = 2
var scrap = 0
var job = "Farming"
var skill = "labour"
func _ready():
	occupency = 3
	Global = get_node("/root/Global") 
	
func turn():
	for farmer in occupents:
		if farmer == null:
			pass
		elif !farmer.get_ref():
			pass
		else:
			harvest_time -= farmer.get_ref().labour_skill
	if harvest_time <= 0:
		Global.food += food
		harvest_time = total_harvest_time

func builder():
	return builder.get_node("four_tile_x/Build")

#func initialize():
#	Global = get_node("/root/Global") 
#	level = get_parent().get_parent()
#	faction = get_parent()
#	get_node("body").set_layer_mask_bit(frontorback, true)
#	myself = weakref(self)
#	faction.defence_list.append(myself)
#	get_node("body").set_layer_mask_bit(faction.sidenumber, true)
#	set_layer_mask_bit(faction.enemynumber, true)
#	set_collision_mask(faction.enemynumber)
