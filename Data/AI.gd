extends Node2D
var buildings = preload("res://Buildings.tscn").instance()
var global_run = true 
var AI = true

var total_infantry = 3
var infantry = 0

var total_walls = 1
var walls = 0

var total_bunkers = 2
var bunkers = 0

var total_HQ = 0
var HQ = 0

var faction
var level
var pos

var build_zone


func _ready():
	faction = get_parent()
	level = get_parent().get_parent()
	faction.player_list.append(self)
	set_fixed_process(true)


func construct_outpost(zone):
	var struct = level.buildings.get_node(faction.faction + "/Spawn_buildings/outpost").duplicate()
	var builder = struct.builder().duplicate()
	var new_AI = self.duplicate()
	builder.structure = struct
	faction.add_child(struct)
	faction.add_child(builder)
	builder.defence_zone.append(zone.get_node("Area2D"))
	struct.flip(faction.flipped)
	struct.set_pos(zone.positions[round((zone.positions.size() - 1)/ 2)].get_global_pos())
	builder.set_pos(zone.positions[round((zone.positions.size() - 1)/ 2)].get_global_pos())
	struct.lev = level
	struct.fact = faction
	new_AI.build_zone = zone
	struct.AI = new_AI
	builder.activate()
		
func building(object, build, pos):
	build.structure = object
	faction.call_deferred("add_child", object)
	faction.call_deferred("add_child", build)
	build.defence_zone.append(build_zone.get_node("Area2D"))
	object.flip(faction.flipped)
	object.set_pos(pos)
	build.set_pos(pos)
	build.call_deferred("activate")
	
func check_build(object):
	var position_ground = false
	var size = object.size
	if (faction.flipped and object.foreground) or (not faction.flipped and object.background):
		var tracking = 0
		for position in build_zone.positions:
			if object.background:
				position_ground = position.background
			elif object.foreground:
				position_ground = position.foreground
			if not position_ground:
				if size <= 1:
					pos = build_zone.positions[tracking - object.size + 1].get_global_pos()
					var number = 0
					for build_size_number in range(object.size):
						if object.background:
							build_zone.positions[tracking - number].background = true
						if object.foreground:
							build_zone.positions[tracking - number].foreground = true
						if build_size_number == object.size:
							break
						number += 1
					break
				else:
					size -=1
			else:
				size = object.size
			tracking += 1
	elif (faction.flipped and object.background) or (not faction.flipped and object.foreground):
		for tracking in range(build_zone.positions.size() - 1, 0, - 1):
#			print (tracking)
			var position = build_zone.positions[tracking]

			if object.background:
				position_ground = position.background
			elif object.foreground:
				position_ground = position.foreground
			if not position_ground:
#				print (size)
				if size <= 1:
					pos = build_zone.positions[tracking].get_global_pos()
#					print("ok")
					var number = 0
					for build_size_number in range(object.size):
						if object.background:
							build_zone.positions[tracking + number].background = true
						elif object.foreground:
							build_zone.positions[tracking + number].foreground = true
						if build_size_number == object.size:
							break
						number += 1
					break
				else:
					size -=1
			else:
				size = object.size

			
func _fixed_process(delta):
	if build_zone.side == faction.side:
		if faction.build_list.size() < faction.builder_list.size():
			pos = null
			if faction.points >= buildings.get_node(faction.faction + "/Spawn_buildings/infantry").cost and infantry < total_infantry:
				check_build(buildings.get_node(faction.faction + "/Spawn_buildings/infantry"))
				if pos != null:
					var inf = buildings.get_node(faction.faction + "/Spawn_buildings/infantry").duplicate()
					call_deferred("building", inf, inf.builder().duplicate(), pos)
					infantry += 1
					faction.points -= buildings.get_node(faction.faction + "/Spawn_buildings/infantry").cost
			if pos == null and faction.points >= buildings.get_node(faction.faction + "/Barricades/tall_steel_wall").cost and walls < total_walls:
				check_build(buildings.get_node(faction.faction + "/Barricades/tall_steel_wall"))
				if pos != null:
					var inf = buildings.get_node(faction.faction + "/Barricades/tall_steel_wall").duplicate()
					call_deferred("building", inf, inf.builder().duplicate(), pos)
					walls += 1
					faction.points -= buildings.get_node(faction.faction + "/Barricades/tall_steel_wall").cost
				
			if pos == null and faction.points >= buildings.get_node(faction.faction + "/Defence/sandbag_bunker").cost and bunkers < total_bunkers:
				check_build(buildings.get_node(faction.faction + "/Defence/sandbag_bunker"))
				if pos != null:
					var inf = buildings.get_node(faction.faction + "/Defence/sandbag_bunker").duplicate()
					call_deferred("building", inf, inf.builder().duplicate(), pos)
					bunkers += 1
					faction.points -= buildings.get_node(faction.faction + "/Defence/sandbag_bunker").cost
						
	if level.game_over:
		set_fixed_process(false)
			
