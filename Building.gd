extends "res://Zones.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
func cell_randomizer():
	for tile_map in get_children():
		if not tile_map.is_in_group("door"):
			for cells in tile_map.get_used_cells():
				tile_map.set_cell(cells.x, cells.y, round(rand_range(0, 1)))
#		for cells in get_node("trim").get_used_cells():
#			get_node("trim").set_cell(cells.x, cells.y, round(rand_range(0, 1)))
#		for cells in get_node("background").get_used_cells():
#			get_node("background").set_cell(cells.x, cells.y, round(rand_range(0, 1)))
func night():
	for tile_map in get_children():
		if not tile_map.is_in_group("door"):
			for cells in tile_map.get_used_cells():
				var coords = tile_map.map_to_world(cells)
				var dark = darkness.get_node("Darkness").duplicate()
				get_parent().get_node("night").add_child(dark)
				dark.set_global_pos(Vector2(coords.x + 10 + get_global_pos().x, coords.y + 10))
				dark.show()
			
func _ready():
	if loaded == false:
		loaded = true
#		cell_randomizer()
#		night()
	# Called every time the node is added to the scene.
	# Initialization here
	pass
