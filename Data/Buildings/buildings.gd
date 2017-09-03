extends Node
var builder = preload("res://Construction.tscn").instance()
var repair_full = false
var repair_list = []
var repair_cap = 2
var health
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
var vehicle = false
var myself
func hit(collider):
	health -= collider.damage
	if health <= 0 and dead == false:
		dead = true
		death()
		
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
	
func flip(flipped):
	if flipped:
		flip_mod = -1
	else:
		flip_mod = 1
	get_node("body").set_scale(Vector2(1 * flip_mod, 1))

	
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
		
	

	
	
	