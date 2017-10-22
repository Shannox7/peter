extends "res://Data/Buildings/buildings.gd"

var name = "Armoury"
var cost = 25
var build_time = 10
var size = 2
var Gun

var frontorback = 8
var object
var fade = 0
var obj_dup
var spawned = false
var spawn_time = 0
var total_spawn_time = 10

var background = true
var foreground = false

var spawn_limit = 6

var weapons = []

var equipping = []

func AI_recount(AI):
	AI.infantry -= 1
	
func builder():
	return builder.get_node("four_tile_x/Build")
	
func _ready():
	level = get_parent().get_parent()
	full = false
	spawn_time = 0
	total_spawn_time = 10
	pass


func initialize():
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
#	if faction.AI and not manual_placed:
#		AI_recount(faction.player_list[0])
#	for spawn in spawns:
#		if !spawn.get_ref():
#			pass
#		else:
#			spawn.get_ref().spawn_home = null
#			spawn.get_ref().orders("attack")
	call_deferred("queue_free")
	
func occupency():
	if weapons.size() > equipping.size() and weapons.size() > 0:
		full = false
	else:
		full = true

func op_dead(op):
	if op.myself in equipping:
		equipping.remove(equipping.find(op.myself))
	occupency()

func add_operator(op):
	equipping.append(op.myself)
	occupency()

func place(op):
	op.equip(level.armour.instance().get_node("Tier_1/head/combathelmet").duplicate(), false, "head")
	weapons.back().get_parent().remove_child(weapons.back())
	op.equip(weapons.back(), false, "primaryGun")
	weapons.pop_back()
	op.defending = false
	op.in_defence = false
	op.orders("attack")
	equipping.remove(equipping.find(op.myself))
	occupency()
		
func spawn(weapon):
	var gun = level.guns.instance().get_node("Soldier_guns/" + str(weapon)).duplicate()
	faction.add_child(gun)
	weapons.append(gun)
	gun.set_global_pos(get_node("body/weapon_area").get_children()[weapons.size() - 1].get_global_pos())
	gun.set_rotd(90)
	occupency()
	
func red():
	get_node("body 1").set_modulate(Color(255, 1, 1))
func original_colour():
	get_node("body 1").set_modulate(Color(1, 1, 1))
	
func _fixed_process(delta):
	if weapons.size() < spawn_limit:
		spawn_time -= delta
		if spawn_time <= 0:
			call_deferred("spawn", "Sniper")
			spawn_time = total_spawn_time

	if level.game_over:
		set_fixed_process(false)
		

