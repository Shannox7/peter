extends Node2D
var points = 10
var positions = []
var buildings = preload("res://Buildings.tscn").instance()

var total_infantry = 4
var infantry = 0
var total_walls = 1
var walls = 0
var total_bunkers = 3
var bunkers = 0

var rebuild_list = []
var faction
var level
var pos
var foreground_build_zone
var background_build_zone
func _ready():
	faction = get_parent()
	level = get_parent().get_parent()
	faction.player_list.append(self)
	zone_check()
	set_fixed_process(true)

func building(object, build, pos, zone):
	build.structure = object
	faction.add_child(object)
	faction.add_child(build)
	build.defence_zone.append(zone)
	object.set_pos(pos)
	build.set_pos(pos)
	build.activate()
	
func zone_check():
	background_build_zone = null
	foreground_build_zone = null
	for zone in level.objective_list:
		if not zone.background_full and zone.side == faction.side:
			background_build_zone = zone
	for zone in level.objective_list:
		if not zone.foreground_full and zone.side == faction.side:
			foreground_build_zone = zone
			break
	
func check_build(object, build_zone):
	var position_ground = false
	var position_ground2 = false
	var size = object.size
	var tracking = 0
	for position in build_zone.positions:
		if object.background:
			position_ground = position.background
		elif object.foreground:
			position_ground = position.foreground
		if not position_ground:
			if size <= 0:
				var number = 1
				for build_size_number in range(object.size):
					if object.background:
						build_zone.positions[tracking - number].background = true
					if object.foreground:
						build_zone.positions[tracking - number].foreground = true
					if number == object.size:
						pos = build_zone.positions[tracking - number].get_global_pos()
						build_zone.check_full()
						zone_check()
						break
					number += 1
				break
			else:
				size -=1
		else:
			size = object.size
		tracking += 1
		

			
func _fixed_process(delta):
	if rebuild_list != []:
		pass
	if background_build_zone != null:
		pos = null
		if faction.points >= buildings.get_node("Spawn_buildings/infantry").cost and infantry != total_infantry:
			check_build(buildings.get_node("Spawn_buildings/infantry"), background_build_zone)
			if pos != null:
				var inf = buildings.get_node("Spawn_buildings/infantry").duplicate()
				building(inf, inf.builder().duplicate(), pos, background_build_zone)
				infantry += 1
				points -= buildings.get_node("Spawn_buildings/infantry").cost

	if foreground_build_zone != null:
		pos = null
		if faction.points >= buildings.get_node("Barricades/tall_steel_wall").cost and walls != total_walls:
			check_build(buildings.get_node("Barricades/tall_steel_wall"), foreground_build_zone)
			if pos != null:
				var inf = buildings.get_node("Barricades/tall_steel_wall").duplicate()
				building(inf, inf.builder().duplicate(), pos, foreground_build_zone)
				walls += 1
				points -= buildings.get_node("Barricades/tall_steel_wall").cost
			
		if faction.points >= buildings.get_node("Defence/sandbag_bunker").cost and bunkers != total_bunkers:
			check_build(buildings.get_node("Defence/sandbag_bunker"), foreground_build_zone)
			if pos != null:
				var inf = buildings.get_node("Defence/sandbag_bunker").duplicate()
				building(inf, inf.builder().duplicate(), pos, foreground_build_zone)
				walls += 1
				points -= buildings.get_node("Defence/sandbag_bunker").cost
			
			
			
