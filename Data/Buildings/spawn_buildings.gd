extends "res://Data/Buildings/buildings.gd"
var frontorback = 8
var object
var fade = 0
var obj_dup
var spawned = false
var spawn_time
var total_spawn_time

var background = true
var foreground = false

var limited = false
var spawn_limit
var spawns = []
func activate():
	set_z(-3)
	set_fixed_process(true)
	set_layer_mask_bit(frontorback, true)
	health = total_health
	level = get_parent().get_parent()
	faction = get_parent()
	faction.defence_list.append(self)
#	set_layer_mask_bit(faction.sidenumber, true)
#	set_layer_mask_bit(faction.enemynumber, true)
#	set_collision_mask_bit(faction.enemynumber, true)
	
func spawn():
	spawned = true
	obj_dup = object.duplicate()
#	obj_dup.set_opacity(0)
	obj_dup.set_pos(get_node("Position2D").get_global_pos())
	faction.add_child(obj_dup)

func red():
	get_node("body").set_modulate(Color(255, 1, 1))
func original_colour():
	get_node("body").set_modulate(Color(1, 1, 1))

func _ready():
	pass


func _fixed_process(delta):
	if not limited:
		spawn_time -= delta
		if spawn_time <= 0:
			spawn()
			spawn_time = total_spawn_time
		if spawned:
			fade += delta
			obj_dup.holding = true
			obj_dup.set_opacity(fade)
			if fade >= 1:
				obj_dup.holding = false
				fade = 0
				spawned = false
				
	elif spawns.size() < spawn_limit:
		spawn_time -= delta
		if spawn_time <= 0:
			spawn()
			spawns.append(obj_dup)
			obj_dup.spawn_home = self
			spawn_time = total_spawn_time
#		if spawned:
#			fade += delta
#			obj_dup.holding = true
#			obj_dup.set_opacity(fade)
#			if fade >= 1:
#				obj_dup.holding = false
#				fade = 0
#				spawned = false
		
			
		