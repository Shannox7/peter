extends Node
var builder = preload("res://Construction.tscn").instance()
var repair_full = false
var repair_list = []
var repair_cap = 1

var occupency = 0
var occupents = []

var health = 100
var total_health = 100
var blowing_up = false
#var build_time = 5
var dead = false
var faction
var level
var full = true
var defence_zone
var manual_placed = false
var flip_mod = 1
var flipped = false
var vehicle = false
var myself
var Global
var resource = false

func turn():
	pass

func red():
	get_node("body 1").set_modulate(Color(255, 1, 1))
func original_colour():
	get_node("body 1").set_modulate(Color(1, 1, 1))
	
func hit(collider):
	health -= collider.damage
	if health <= 0 and dead == false:
		dead = true
		death()

func remove_occupent(slot):
	if occupents[slot] == null:
		pass
	elif !occupents[slot].get_ref():
		occupents[slot] = null
	elif occupents[slot].get_ref().get_parent() == get_node("body"):
		occupents[slot].get_ref().swap()
		occupents[slot].get_ref().get_parent().remove_child(occupents[slot].get_ref())
		occupents[slot].get_ref().defending = false
		occupents[slot].get_ref().placed = false
		faction.add_child(occupents[slot].get_ref())
		occupents[slot].get_ref().set_global_pos(get_node("body/defence_pos").get_global_pos())
		occupents[slot].get_ref().set_fixed_process(true)
		occupents[slot].get_ref().flip(flipped)
	else:
		occupents[slot].get_ref().defending = false
		occupents[slot].get_ref().set_fixed_process(true)
		
	occupents[slot].get_ref().placed = false
	occupents[slot].get_ref().building = null
	occupents[slot].get_ref().job = ''
	occupents[slot].get_ref().objective = null
	occupents[slot].get_ref().orders("patrol")
	occupents[slot] = null
func remove_positioning():
	var number = 0
	for position in defence_zone.positions: 
		if position.get_global_pos().x == get_global_pos().x:
			break
		number += 1
	var place = 0
	for width in range(self.size):
		if self.background:
			defence_zone.positions[number + place].background = false
		if self.foreground:
			defence_zone.positions[number + place].foreground = false
		place += 1
		
func death():
	faction.defence_list.remove(faction.defence_list.find(myself))
	for builders in repair_list:
		if !builders.get_ref():
			pass
		elif not builders.get_ref().dead:
			builders.get_ref().orders("waiting")
			builders.get_ref().build()
	call_deferred("remove_positioning")
	if faction.AI and not manual_placed:
		AI_recount(faction.player_list[0])
	call_deferred("queue_free")
	
func flip(flipping):
	if flipping:
		flipped = true
		flip_mod = -1
	else:
		flipped = false
		flip_mod = 1
	get_node("body").set_scale(Vector2(1 * flip_mod, 1))

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
	pass

func place(npc):

	npc.animNode.play("idle")
	npc.placed = true
	npc.set_global_pos(get_global_pos())
	npc.set_fixed_process(false)

func positioning():
	var number = 0
	for position in defence_zone.positions:
		if position.get_global_pos().x == get_global_pos().x:
			break
		number += 1
	var place = 0
	for width in range(self.size):
		if self.background:
			defence_zone.positions[number + place].background = true
		if self.foreground:
			defence_zone.positions[number + place].foreground = true
		place += 1
		
	

	
	
	