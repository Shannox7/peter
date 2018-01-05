extends Node
var map = preload("res://Campaign_map.tscn").instance()
var attacks = preload("res://Attacks.tscn").instance()
var effects = preload("res://effects.tscn").instance()
var AI = preload("res://AI.tscn").instance()
var player = preload("res://Peter.tscn").instance()
var Guns = preload("res://Guns.tscn").instance()
var armour = preload("res://armour.tscn").instance()
var enemies = preload("res://Enemies.tscn").instance()
var level_generator = preload("res://Level_generator.tscn").instance()
var area_generator = preload("res://Area_generator.tscn").instance()
var Zones = preload("res://Zones.tscn").instance()
var Base = preload("res://Base.tscn").instance()
var limbs = preload("res://Limbs.tscn").instance()
var gen = preload("res://npc_parts.tscn").instance()
var resource = preload("res://resource.tscn").instance()
var gun_parts = preload("res://Gun_parts.tscn").instance()
var Card = preload("res://Card.tscn").instance()
var Float = preload("res://Floating_dialogue.tscn").instance()
var traps = preload("res://traps.tscn").instance()

#var root
var current_scene = null
var current_level
var current_area
var tree_list = []
var supply_run_carry_weight = 0
var supply_run_weight = 0
var supply_run_pack = []
var on_supply_run = false

var supply_runs = []
var running_events = []
var party = []

var day = 1
#values
var food = 20
var scrap = 20
var medicine = 5
var pack = []

onready var root = get_tree().get_root()
#var base_size
onready var base_size = root.get_rect().size

var area_list = []
var chasing_list = []

var assault_number = 20
func assault():
	player.level.spawn(20) 
#
#func _on_screen_resized():
#   
#    var new_window_size = OS.get_window_size()
#    OS.set_window_size(Vector2(max(base_size.x, new_window_size.x), max(base_size.y, new_window_size.y)))
#
#    var scale_w = max(int(new_window_size.x / base_size.x), 1)
#    var scale_h = max(int(new_window_size.y / base_size.y), 1)
#    var scale = min(scale_w, scale_h)
#
#    var diff = new_window_size - (base_size * scale)
#    var diffhalf = (diff * 0.5).floor()
#
#    root.set_rect(Rect2(Vector2(), base_size))
#    root.set_render_target_to_screen_rect(Rect2(diffhalf, base_size * scale))

func _ready():
	var body = armour.get_node("Tier_1/body/flakjacket").duplicate()
	body._ready()
	var helm = armour.get_node("Tier_1/head/combathelmet").duplicate()
	helm._ready()
	var ak = Guns.get_node("Soldier_guns/AK47").duplicate()
	ak._ready()
	pack = [helm]
	root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )
#	root.connect("size_changed", self, "position")
#	position()

#	get_tree().connect("screen_resized", self, "_on_screen_resized")
#	root.set_size_override_stretch(false)
#	root.set_size_override(false, Vector2())

#	root.set_as_render_target(true)
#	root.set_render_target_update_mode(root.RENDER_TARGET_UPDATE_ALWAYS)
#	root.set_render_target_to_screen_rect(root.get_rect())
	
#	base_size = root.get_rect().size
func position():
	current_scene.set_pos(Vector2(0, get_viewport().get_rect().size.y))

func free_up(survivor):
	survivor.get_ref().building = null
	survivor.get_ref().job = ''
	survivor.get_ref().objective = null
	if survivor.get_ref().AI:
		survivor.get_ref().orders("patrol")

func calculate(event):
	var success = false
	for npc in event.get_ref().occupents:
		if npc != null:
			event.get_ref().fight += npc.get_ref().fight_skill
	event.get_ref().difficulty -= event.get_ref().fight
	var random = int(rand_range(0, 101))
	if random <= event.get_ref().difficulty:
		success = false
	else:
		success = true
	if not success:
		for npc in event.get_ref().occupents:
			var random = int(rand_range(0, 101))
			if npc != null:
				if random <= 10:
					npc.get_ref().injure()
#				if random <= 10 and random >=3:
#					npc.get_ref().injure()
#				elif random <= 2:
#					npc.get_ref().die_on_mission()
	else:
		food += event.get_ref().food
		medicine += event.get_ref().medicine
		scrap += event.get_ref().scrap
	
	Base.report.call_deferred("report", event, success)
	
#	if event.get_ref().get_parent() != null:
#		event.get_ref().get_parent().remove_child(event.get_ref())
	event.get_ref().call_deferred("free")
	Base.events.call_deferred("turn")

	#raise chance of success by fight rating while lowering it vs difficulty
#	print(event.get_ref().fight)

func result():
	for event in running_events:
		if not player.myself in event.get_ref().occupents:
			call_deferred('calculate', event)
		else:
			Base.events.event_list.remove(Base.events.event_list.find(event.get_ref().myself))
			event.get_ref().call_deferred("free")
	for item in supply_run_pack:
		if item.is_in_group("resource"):
			if item.scrap >0:
				scrap += item.scrap
				pass
			if item.food >0:
				food += item.food
				pass
			if item.medicine >0:
				medicine += item.medicine
			item.free()
		elif item in pack:
			pass
		else:
			pack.append(item)

func load_room(path, from, loaded, enter):
	tree_list.append(from)
	call_deferred("deferred_load_room", path, from, loaded, enter)
	
func deferred_load_room(path, from, loaded, enter):
	from.get_parent().remove_child(from)
	if loaded:
		chased(from, path)
		root.add_child(path)
		current_scene = path
		pass
	else:
		var s = Zones.get_node(path).get_children()[round(rand_range(0, Zones.get_node(path).get_children().size() - 1))].duplicate()
		enter.area = s
		s.door_colour = enter.get_node("closed").get_modulate()
		chased(from, s)
		s.get_node("Building/Trim").set_tileset(enter.get_parent().get_node("Building/Trim").get_tileset())
		s.get_node("Building/Base").set_tileset(enter.get_parent().get_node("Building/Base").get_tileset())
		s.get_node("Building/Top").set_tileset(enter.get_parent().get_node("Building/Top").get_tileset())
		s.get_node("Building/inside_wall_colour").set_tileset(enter.get_parent().get_node("Building/inside_wall_colour").get_tileset())
		s.get_node("Building/inside_wall_trim").set_tileset(enter.get_parent().get_node("Building/inside_wall_trim").get_tileset())
		root.add_child(enter.area)
		current_scene = s

func chased(from, to):
	if from.chase_list != []:
#		chasing_list = from.chase_list
		for enemy in from.chase_list:
			chasing_list.append(enemy)
#		to.chase_list = from.chase_list
		from.chase_list = []
		to.chased()
	

func load_building(path, from, loaded, enter):
	tree_list.append(from)
	call_deferred("deferred_load_building", path, from, loaded, enter)
	
func deferred_load_building(path, from, loaded, enter):
	current_level = from
	current_area.get_parent().remove_child(current_area)
	if loaded:
		chased(from, path)
		root.add_child(path)
		current_scene = path
		pass
	else:
		var s = Zones.get_node(path).get_children()[round(rand_range(0, Zones.get_node(path).get_children().size() - 1))].duplicate()
		enter.area = s
		s.door_colour = enter.get_node("closed").get_modulate()
		chased(from, s)
		s.get_node("Building/Trim").set_tileset(enter.get_parent().get_node("Trim").get_tileset())
		s.get_node("Building/Base").set_tileset(enter.get_parent().get_node("Base").get_tileset())
		s.get_node("Building/Top").set_tileset(enter.get_parent().get_node("Top").get_tileset())
		s.get_node("Building/inside_wall_colour").set_tileset(enter.get_parent().get_node("inside_wall_colour").get_tileset())
		s.get_node("Building/inside_wall_trim").set_tileset(enter.get_parent().get_node("inside_wall_trim").get_tileset())
		root.add_child(enter.area)
		current_scene = s
		
func return_from(from):
	call_deferred("deferred_return_from", from)

func deferred_return_from(from):
	chased(from, tree_list.back())
	from.get_parent().remove_child(from)
	root.add_child(tree_list.back())
	tree_list.pop_back()
	pass

func return_from_building(from):
	call_deferred("deferred_return_from_building", from)

func deferred_return_from_building(from):
	chased(from, current_level)
	from.get_parent().remove_child(from)
	root.add_child(current_area)

func back_to_base():
	call_deferred("deferred_base")
	
func deferred_base():
	on_supply_run = false
	current_scene.free()
	day += 1
	call_deferred("result")

	root.call_deferred("add_child", Base)
	Base.call_deferred("dusk")
	current_scene = Base
	call_deferred('clear', party)
	call_deferred('clear', supply_run_pack)
	call_deferred('clear', running_events)
	supply_run_carry_weight = 0
	supply_run_weight = 0
	pass
	
func running_events():
	for event in Base.events.event_list:
		for occupent in event.get_ref().occupents:
			if occupent != null:
				if event in running_events:
					pass
				else:
					running_events.append(event)
	
func load_level(street, from_road):
	call_deferred("load_lev", street, from_road)

func load_lev(street, from_road):
	var area = from_road.get_parent().get_parent().get_parent()
	from_road.get_parent().get_parent().get_parent().remove_child(from_road.get_parent().get_parent())
	for road in street.roads:
		if road.road == from_road.get_parent().get_parent():
			street.get_node("player_pos").set_global_pos(road.get_node("travel/Area2D/Position2D").get_global_pos())
			chased(from_road.get_parent().get_parent(), road)
#	street.get_parent().remove_child(street)
	area.call_deferred("add_child", street)

func load_test(menu):
	call_deferred("testing", menu)
func testing(menu):
	menu.get_parent().remove_child(menu)
	root.add_child(Base)
	

func generate_area(type, menu):
	call_deferred("gen_area", type, menu)

func gen_area(type, menu):
	on_supply_run = true
#	party = player.building.get_ref().occupents
#	for npc in party:
#		if npc != null:
#			if npc.get_ref().primaryGun != []:
#				supply_run_pack.append(npc.get_ref().primaryGun[0])
#			elif npc.get_ref().headArmour != []:
#				supply_run_pack.append(npc.get_ref().headArmour[0])
#			elif npc.get_ref().bodyArmour != []:
#				supply_run_pack.append(npc.get_ref().bodyArmour[0])
#			supply_run_carry_weight += npc.get_ref().carry_weight
			
	menu.get_parent().remove_child(menu)
	var s = area_generator.duplicate()
	current_area = s
	area_list.append(s)
	root.add_child(current_area)
	s.generate_area(type)
	s.call_deferred("start")
	
func generate_level(type):
	call_deferred("gen_lev", type)

func gen_lev(type):
	on_supply_run = true
	party = player.building.get_ref().occupents
	for npc in party:
		if npc != null:
			if npc.get_ref().primaryGun != []:
				supply_run_pack.append(npc.get_ref().primaryGun[0])
			elif npc.get_ref().headArmour != []:
				supply_run_pack.append(npc.get_ref().headArmour[0])
			elif npc.get_ref().bodyArmour != []:
				supply_run_pack.append(npc.get_ref().bodyArmour[0])
			supply_run_carry_weight += npc.get_ref().carry_weight
			
	Base.get_parent().remove_child(Base)
	var s = level_generator.duplicate()
	s.generate_level(type, 5)
	current_scene = s
	root.add_child(current_scene)


	
#func generate_attack(Map, attackers, defenders, attacker_force):
#	Map.get_parent().remove_child(Map)
#	var s = ResourceLoader.load("res://Level.tscn")
#	current_scene = s.instance()
#	root.add_child(current_scene)
#	current_scene.battle_set_up(attackers, defenders, attacker_force)

func load_map(Base, map):
#	Base.get_parent().remove_child(Base)
	get_tree().get_root().add_child(map)
	
func unload_map(Base):
	map.get_parent().remove_child(map)
	get_tree().get_root().add_child(Base)
	
func goto_scene(path):

    # This function will usually be called from a signal callback,
    # or some other function from the running scene.
    # Deleting the current scene at this point might be
    # a bad idea, because it may be inside of a callback or function of it.
    # The worst case will be a crash or unexpected behavior.

    # The way around this is deferring the load to a later time, when
    # it is ensured that no code from the current scene is running:

    call_deferred("_deferred_goto_scene",path)


func _deferred_goto_scene(path):

    # Immediately free the current scene,
    # there is no risk here.
    current_scene.free()

    # Load new scene
    var s = ResourceLoader.load(path)

    # Instance the new scene
    current_scene = s.instance()

    # Add it to the active scene, as child of root
    get_tree().get_root().add_child(current_scene)

    # optional, to make it compatible with the SceneTree.change_scene() API
    get_tree().set_current_scene( current_scene )