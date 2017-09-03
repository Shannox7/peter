extends Area2D
var obstructions = []
var defence_zone = []
var placed = false
var placeable = false
var structure
var builders = []
var builder_size = 1
var builder_time = 0
var build_time
var full = false
var side
var enemy
var sidenumber
var enemynumber
var sidebuildlist
var sidelist
var built_animation_time = 2.0
var structure_pos
var delta
var faction
var level
var myself
var dead = false
func _ready():
	set_z(structure.get_z())
	level = get_parent().get_parent()
	faction = get_parent()
	set_layer_mask_bit(structure.frontorback, true)
	set_collision_mask_bit(structure.frontorback, true)
	hide_animations()
	set_fixed_process(true)
	connect("body_enter", self, "non_buildable")
	connect("body_exit", self, "buildable")
	connect("area_enter", self, "defence_area") 
	connect("area_exit", self, "defence_area_exit")

func occupency():
	if builders.size() == builder_size:
		full = true
	else:
		full = false

func activate():
	placed = true
	if faction.AI or structure.cost == null:
		pass
	else:
		defence_zone.front().get_parent().red = true
		positioning()
	build_time = structure.build_time
	structure.hide()
	structure_pos = structure.get_pos()
	myself = weakref(self)
	faction.build_list.append(myself)
	show_animations()
	get_node("collider").set_layer_mask_bit(structure.frontorback, true)
	build()

func positioning():
	var ground
	var number = 0
	for position in defence_zone.front().get_parent().positions:
		if position.get_global_pos().x == get_global_pos().x:
			break
		number += 1
	var place = 0
	for width in range(structure.size):
		if structure.background:
			defence_zone.front().get_parent().positions[number + place].background = true
		if structure.foreground:
			defence_zone.front().get_parent().positions[number + place].foreground = true
		place += 1

func remove(builder):
	builders.remove(builders.find(builder.myself))
	occupency()

func close():
	set_fixed_process(false)
	faction.build_list.remove(faction.build_list.find(myself))
	for engineers in builders:
		engineers.get_ref().orders("waiting")
		engineers.get_ref().build()
	call_deferred("queue_free")
	
func build():
	if not full:
		for npc in faction.builder_list:
			if not npc.get_ref().building:
				npc.get_ref().orders("build")
				npc.get_ref().objective = self
				builders.append(npc.get_ref().myself)
				occupency()

func non_buildable(collider):
	placeable = false
	obstructions.append(collider)
func buildable(collider):
	obstructions.pop_front()
func defence_area(area):
	if area.is_in_group("defence_zone") and area.get_parent().side == faction.side and not faction.AI and structure.cost != null:
		defence_zone.append(area)
		area.get_parent().green()

func defence_area_exit(area):
	if area.is_in_group("defence_zone") and not faction.AI and structure.cost != null:
		defence_zone.pop_front()
		area.get_parent().red()

func destroy():
	faction.build_list.remove(faction.build_list.find(myself))
	for b in builders:
		if not b.get_ref().dead:
			b.get_ref().building = false
			b.get_ref().build()
	structure.call_deferred("queue_free")
	call_deferred("queue_free")

func _fixed_process(delta):
	placeable()
	if placeable == true and not faction.AI:
		structure.original_colour()
	elif not faction.AI and structure.cost != null:
		structure.red()
	if placed == true:
		if build_time <= built_animation_time:
			structure.show()
			structure.set_z(-2)
			structure.set_pos(Vector2(structure_pos.x, structure_pos.y + build_time * 20))
			if build_time <= 0:
				structure.set_pos(structure_pos) 
				structure.set_z(1)
				structure.defence_zone = defence_zone.front().get_parent()
				structure.initialize()
				close()
