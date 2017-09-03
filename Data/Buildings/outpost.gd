extends "res://Data/Buildings/spawn_buildings.gd"
var name = "HQ"
var cost = null
var build_time = 10
var size = 3

var AI
var fact
var lev

func initialize():
	if AI != null:
		get_parent().remove_child(self)
		fact.add_child(AI)
		fact.player_list.append(AI)
		fact.add_child(self)
	set_z(-3)
	set_fixed_process(true)
	get_node("body").set_layer_mask_bit(frontorback, true)
	health = total_health
	level = get_parent().get_parent()
	faction = get_parent()
	myself = weakref(self)
	faction.defence_list.append(myself)
	get_node("body").set_layer_mask_bit(faction.sidenumber * 3, true)
func AI_recount(AI):
	AI.HQ -= 1
	
func builder():
	return builder.get_node("three_tile_x/Build")
	
func _ready():
	spawn_time = 0
	total_spawn_time = 10
	spawn_limit = 1
	limited = true
	object = preload("res://Allies.tscn").instance().get_node("Engineer")
	pass
