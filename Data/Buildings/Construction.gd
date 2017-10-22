extends Area2D
var name = "Construction"
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

var occupents = []
var occupency = 2
var job = "Building"

func turn():
	for builder in occupents:
		if builder == null:
			pass
		elif !builder.get_ref():
			pass
		else:
			build_time -= builder.get_ref().labour_skill
	structure.show()
	if build_time <= 0:
		structure.set_pos(structure_pos) 
		structure.defence_zone = defence_zone.front().get_parent()
		structure.initialize()
		close()
	else:
		structure.set_pos(Vector2(structure_pos.x, structure_pos.y + build_time * 10))

func _ready():
	occupency()
	set_z(structure.get_z())
	level = get_parent().get_parent()
	faction = get_parent()
	set_collision_mask_bit(structure.frontorback, true)
	
	
	if not placed:
		hide_animations()
		set_fixed_process(true)
		connect("body_enter", self, "non_buildable")
		connect("body_exit", self, "buildable")
		connect("area_enter", self, "defence_area") 
		connect("area_exit", self, "defence_area_exit")
		
func remove_occupent(slot):
	if occupents[slot] == null:
		pass
	elif !occupents[slot].get_ref():
		occupents[slot] = null
	elif occupents[slot].get_ref().get_parent() == self:
		occupents[slot].get_ref().swap()
		occupents[slot].get_ref().get_parent().remove_child(occupents[slot].get_ref())
		occupents[slot].get_ref().defending = false
		occupents[slot].get_ref().in_defence = false
		faction.add_child(occupents[slot].get_ref())
		occupents[slot].get_ref().set_global_pos(get_node("body/defence_pos").get_global_pos())
		occupents[slot].get_ref().set_fixed_process(true)
	else:
		occupents[slot].get_ref().defending = false
		occupents[slot].get_ref().orders("patrol")
		occupents[slot].get_ref().set_fixed_process(true)
		
	occupents[slot].get_ref().building = null
	occupents[slot].get_ref().job = ''
	occupents[slot].get_ref().objective = null
	occupents[slot].get_ref().orders("patrol")
	occupents[slot] = null
	
func occupy(npc, slot):
	npc.building = myself
	occupents[slot] = npc.myself
	npc.objective = myself
	npc.orders("occupy")
	occupents[slot].get_ref().job = self.job
	pass

func occupency():
	for number in range(occupency):
		occupents.append(null)

func place(npc):
	npc.set_global_pos(get_global_pos())
	npc.set_fixed_process(false)

func show_animations():
	get_node("body 1").show()
func hide_animations():
	get_node("body 1").hide()

func placeable():
	var can_place = true
	for rays in get_node("colliders").get_children():
		if not rays.is_colliding():
			can_place = false
			break
	if obstructions != []:
		can_place = false
	if defence_zone != []:
		var defence_pos = defence_zone[0].get_parent().positions
		if get_global_pos().x > defence_pos[defence_pos.size() - (structure.size)].get_global_pos().x or get_global_pos().x < defence_pos.front().get_global_pos().x:
			can_place = false
	else:
		can_place = false
	return can_place
	
#func occupency():
#	for builder in range(builders.size() - 1):
#		if !builders[builder].get_ref():
#			builders.remove(builder)
#	if builders.size() == builder_size:
#		full = true
#	else:
#		full = false
#	if  builders.size() > builder_size:
#		remove(builders.back().get_ref())

func activate():
	set_layer_mask_bit(structure.frontorback, true)
	placed = true
	if faction.AI or structure.cost == null:
		pass
	else:
		defence_zone.front().get_parent().red = true
		positioning()
	build_time = structure.build_time
	name = "Constructing: " + structure.name
	structure.hide()
	set_z(structure.get_z() + 1)
	structure_pos = structure.get_pos()
	myself = weakref(self)
	faction.defence_list.append(myself)
	show_animations()
	get_node("collider").set_layer_mask_bit(structure.frontorback, true)
	disconnect("body_enter", self, "non_buildable")
	disconnect("body_exit", self, "buildable")
	disconnect("area_enter", self, "defence_area") 
	disconnect("area_exit", self, "defence_area_exit")

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

#func remove(builder):
#	builders.remove(builders.find(builder.myself))
#	occupency()
#	builder.build()

func close():
	dead = true
	set_fixed_process(false)
	faction.defence_list.remove(faction.defence_list.find(myself))
	var number = 0
	for builder in occupents:
		if builder == null:
			pass
		elif !builder.get_ref():
			pass
		else:
			remove_occupent(number)
		number += 1
	call_deferred("queue_free")
#	
#func build():
#	if not full:
#		for npc in faction.builder_list:
#			if !npc.get_ref():
#				pass
#			elif not npc.get_ref().building:
#				npc.get_ref().orders("build")
#				npc.get_ref().objective = self
#				builders.append(npc.get_ref().myself)
#				occupency()

func non_buildable(collider):
	placeable = false
	obstructions.append(collider)
func buildable(collider):
	obstructions.pop_front()
func defence_area(area):
	if not dead:
		if area.is_in_group("defence_zone") and area.get_parent().side == faction.side and not faction.AI and structure.cost != null:
			defence_zone.append(area)
			area.get_parent().green()

func defence_area_exit(area):
	if not dead:
		if area.is_in_group("defence_zone") and not faction.AI and structure.cost != null:
			defence_zone.remove(defence_zone.find(area))
			area.get_parent().red = true

func destroy():
	dead = true
	faction.build_list.remove(faction.build_list.find(myself))
	for b in builders:
		if !b.get_ref():
			pass
		elif not b.get_ref().dead:
			b.get_ref().build()
	structure.call_deferred("queue_free")
	call_deferred("queue_free")
	

func _fixed_process(delta):
	placeable = placeable()
	if placeable == true and not faction.AI:
		structure.original_colour()
	elif not faction.AI and structure.cost != null:
		structure.red()
#	if placed == true:
#		if build_time <= built_animation_time:
#			structure.show()
#			structure.set_pos(Vector2(structure_pos.x, structure_pos.y + build_time * 20))
#			if build_time <= 0:
#				structure.set_pos(structure_pos) 
#				structure.defence_zone = defence_zone.front().get_parent()
#				structure.initialize()
#				close()
