extends Node2D
#var level = preload("res://Level_generator.tscn").instance()
var m = preload("res://miniimap_HUD.tscn").instance()
var loader
var base

var minimap
var levels = [[],[]]

var road_signsx = ["Main st", "Hickory st", "Pleasent st", "Rockaway st", "King st"]
var road_signsy = ["Armour st", "Shannon st", "Knollwhere st", "Weber Ave", "Hazel st"]


var size = 5
#var zones = preload("res://Zones.tscn").instance()

var start_lev
var start

func _ready():
	loader = get_node("/root/resource_queue")
	pass

func generate_minimap():
	minimap = m.duplicate()
	var front = true
	var tile = minimap.get_node("Control/TileMap")
	var posx = 0
	for nodes in levels[0][0].nodes:
		tile.set_cell(posx, 0, nodes.icon)
		nodes.map_coords = [posx, 0]
		if nodes in levels[0][0].roads:
			var posy = 0
			for node in nodes.road.nodes:
				node.map_coords = [posx, posy]
				tile.set_cell(posx, posy, node.icon, false, true, true)
				posy += 1
		posx += 1
	var posy = 0
	for nodes in levels[1][0].nodes:
		nodes.map_coords = [0, posy]
		tile.set_cell(0, posy, nodes.icon, false, true, true)
		if nodes in levels[1][0].roads:
			var posx = 0
			for node in nodes.road.nodes:
				node.map_coords = [posx, posy]
				tile.set_cell(posx, posy, node.icon)
				posx += 1
		posy += 1


	add_child(minimap)
func start():
	start_lev.get_node("player_pos").set_global_pos(start)
	call_deferred("generate_minimap")
	call_deferred("add_child", start_lev)


func generate_area(type):
	loader.start()
	loader.queue_resource("res://Zones.tscn")
	base = loader.get_resource("res://Zones.tscn").instance().get_node("City/Base")
#	base = zones.get_node("City/Base").duplicate()
	var base_numb = round(rand_range(0, 2))
	var base_number = round(rand_range(0, size - 1))
	
	var base_loc = round(rand_range(0, size -1))
	var base_index = round(rand_range(0, 1))
	var base_lev = null
	for number in range(size):
		loader.start()
		loader.queue_resource("res://Level_generator.tscn")
		var level_dup = loader.get_resource("res://Level_generator.tscn").instance()
#		print(level_dup)
#		print(loader.get_progress("res://Level_generator.tscn"))
		if number == base_loc and base_index == 1:
#			level_dup.add_child(base)
#			level_dup.nodes.append(base)
			base_lev = base
			start = base.get_node("player_pos").get_global_pos()
			start_lev = level_dup
		else:
			base_lev = null
		level_dup.area = self
		level_dup.loader = loader
		level_dup.call_deferred("generate_level", type, size, "x", base_lev, base_number, base_numb)
		level_dup.road_sign = road_signsx[number]
		levels[1].append(level_dup)
	for number  in range(size):
		loader.start()
		loader.queue_resource("res://Level_generator.tscn")
		var level_dup = loader.get_resource("res://Level_generator.tscn").instance()
		if number == base_loc and base_index == 0:
#			level_dup.add_child(base)
#			level_dup.nodes.append(base)
			base_lev = base
			start = base.get_node("player_pos").get_global_pos()
			start_lev = level_dup
		else:
			base_lev = null

		level_dup.area = self
		level_dup.loader = loader
		level_dup.call_deferred("generate_level", type, size, "y", base_lev, base_number, base_numb)
		level_dup.road_sign = road_signsy[number]
		levels[0].append(level_dup)
		
	for level in levels[0]:
		level.call_deferred("attach_roads", levels[1])
	for level in levels[1]:
		level.call_deferred("attach_roads", levels[0])
	pass