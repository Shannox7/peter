extends "res://Data/Buildings/buildings.gd"
var frontorback = 8
var object
var fade = 0
var obj_dup
var spawned = false
var spawn_time
var total_spawn_time


var soldier = false

var background = true
var foreground = false

var limited = false
var spawn_limit = 0
var spawns = []
func initialize():
	init()
	set_fixed_process(true)
	get_node("body").set_layer_mask_bit(frontorback, true)
	health = total_health
	level = get_parent().get_parent()
	faction = get_parent()
	myself = weakref(self)
	faction.defence_list.append(myself)
	get_node("body").set_layer_mask_bit(faction.sidenumber * 3, true)
#	set_layer_mask_bit(faction.enemynumber, true)
#	set_collision_mask_bit(faction.enemynumber, true)

func death():
	dead = true
	faction.defence_list.remove(faction.defence_list.find(myself))
	for builders in repair_list:
		if !builders.get_ref():
			pass
		elif not builders.get_ref().dead:
			builders.get_ref().repairing = false
			builders.get_ref().build()
	call_deferred("remove_positioning")
	if faction.AI and not manual_placed:
		AI_recount(faction.player_list[0])
	for spawn in spawns:
		if !spawn.get_ref():
			pass
		elif spawn.get_ref().has_method("repairing"):
			spawn.get_ref().spawn_home = null
			spawn.get_ref().build()
		else:
			spawn.get_ref().spawn_home = null
			spawn.get_ref().orders("attack")
	call_deferred("queue_free")

func spawn(limited):
	obj_dup = object.duplicate()
	obj_dup.spawn_home = myself
	obj_dup.faction = faction
	obj_dup.level = level
#	obj_dup.set_opacity(0)
	faction.add_child(obj_dup)
	obj_dup.set_global_pos(get_node("body/Position2D").get_global_pos())
	if limited:
		spawns.append(obj_dup.myself)

#	spawned = true

func red():
	get_node("body 1").set_modulate(Color(255, 1, 1))
func original_colour():
	get_node("body 1").set_modulate(Color(1, 1, 1))

func _ready():
	pass


func _fixed_process(delta):
	if soldier and faction.soldiers < faction.max_soldiers:
		spawn_time -= delta
		if spawn_time <= 0:
			spawn(false)
			spawn_time = total_spawn_time
			faction.soldiers += 1
#	elif not limited:
#		if soldier and faction.attacker_list.size() >= faction.max_soldiers:
#			pass
#		else:
#			spawn_time -= delta
#		if spawn_time <= 0:
#			spawn(false)
#			spawn_time = total_spawn_time
#		if spawned:
#			fade += delta
#			obj_dup.holding = true
#			obj_dup.set_opacity(fade)
#			if fade >= 1:
#				obj_dup.holding = false
#				fade = 0
#				spawned = false
				
	elif spawns.size() < spawn_limit:
		spawn_time -= delta
		if spawn_time <= 0:
			call_deferred("spawn", true)
			spawn_time = total_spawn_time
			
#	if spawned:
#		fade += delta
#		obj_dup.holding = true
#		obj_dup.set_opacity(fade)
#		if fade >= 1:
#			obj_dup.holding = false
#			fade = 0
#			spawned = false
	if level.game_over:
		set_fixed_process(false)
		
			
		