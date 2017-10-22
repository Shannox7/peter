extends Node
var map = preload("res://Campaign_map.tscn").instance()
var AI = preload("res://AI.tscn").instance()
var player = preload("res://Peter.tscn").instance()
var Base
var root
var current_scene = null

var supply_runs = []
var running_events = []
var party = []

var day = 1
#values
var food = 0
var scrap = 0
var medicine = 0

		
func _ready():
	root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )
	
#func goto_butkeep_scene(path):
#	 call_deferred("_deferred_goto_butkeep_scene",path)
#	
#func _deferred_goto_butkeep_scene(path):
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
				if random <= 10 and random >=3:
					npc.get_ref().injured()
				elif random <= 2:
					npc.get_ref().die_on_mission()
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
		if player.building.get_ref() == null:
			calculate(event)
		elif player.building.get_ref() == event.get_ref():
			event.get_ref().call_deferred("free")
		else:
			calculate(event)
func back_to_base():
	call_deferred("deferred_base")
	
func deferred_base():
	current_scene.free()
	day += 1
	call_deferred('result')

	root.call_deferred("add_child", Base)
	Base.call_deferred("dusk")

	call_deferred('clear', running_events)
	pass
	
func running_events():
	for event in Base.events.event_list:
		for occupent in event.get_ref().occupents:
			if occupent != null:
				if event in running_events:
					pass
				else:
					running_events.append(event)
	print(running_events)
	
func generate_level(path):
	call_deferred("gen_lev", path)
	
func gen_lev(path):
	party = player.building.get_ref().occupents
	Base.get_parent().remove_child(Base)
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
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