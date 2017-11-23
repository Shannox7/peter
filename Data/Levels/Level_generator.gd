extends Node2D
#var zones = preload("res://Zones.tscn").instance()
var faction
var enemy_faction
var Global
var loader
var area
var roads = []
var road_sign = ''
var index

var nodes = []

var camera_limit
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	faction = get_node("Faction")
	enemy_faction = get_node("Enemy_faction")
	Global = get_node("/root/Global")
	if Global.player.get_parent() != null:
		Global.player.get_parent().remove_child(Global.player)
	Global.player.set_global_pos(get_node("player_pos").get_global_pos())
	Global.player.faction = faction
	Global.player.level = self
	faction.call_deferred("add_child", Global.player)
	Global.Base = self
#	Global.player.get_node("Camera2D").set_limit(2, camera_limit)
#	Global.player.get_node("Camera2D").set_limit(0, 0)
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func generate_level(type, size, xy, base, base_number, base_numb):
	loader.start()
	loader.queue_resource("res://Zones.tscn")
	var zones = loader.get_resource("res://Zones.tscn").instance()
	var road_signs
	if xy == "x":
		index = 1
		road_signs = area.road_signsy
	else:
		index = 0
		road_signs = area.road_signsx
	
	var last_zone = null
#	if base != null:
#		last_zone = base
	
	for number in range(size):
		var zone_dup
		zone_dup = zones.get_node(str(type) +  "/Road/road" + str(round(rand_range(0, zones.get_node(str(type) +  "/Road").get_children().size() - 1))))
#		zone_dup = zones.duplicate()
		roads.append(zone_dup)
		nodes.append(zone_dup)
		call_deferred("add_child", zone_dup)
		if last_zone == null:
			pass
		else:
			zone_dup.set_global_pos(last_zone.get_node("end").get_global_pos())
		last_zone = zone_dup
		if number < size - 1:
			for numb in range(3):
				if base != null and number == base_number and numb == base_numb:
					zone_dup = base
				else:
					zone_dup = zones.get_node(str(type) +  "/Street/block" + str(round(rand_range(0, zones.get_node(str(type) +  "/Road").get_children().size() - 1))))
#					zone_dup = zones.get_node(str(type) +  "/Street/block" + str(round(rand_range(0, zones.get_node(str(type) +  "/Street").get_children().size() - 1)))).duplicate()
				call_deferred("add_child", zone_dup)
				nodes.append(zone_dup)
				if last_zone == null:
					pass
				else:
					zone_dup.set_global_pos(last_zone.get_node("end").get_global_pos())
				last_zone = zone_dup
		camera_limit = last_zone.get_node("end").get_global_pos().x
func attach_roads(levels):
	var number = 0
	for road in roads:
		road.road = levels[number]
		road.road_sign = levels[number].road_sign
		number += 1