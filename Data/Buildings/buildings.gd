extends StaticBody2D
var builder = preload("res://Construction.tscn").instance()
var repair_full = false
var repair_list = []
var repair_cap = 2
var health
var total_health = 100
#var build_time = 5
var dead = false
var faction
var level
var full = true
var defence_zone

func hit(collider):
	health -= collider.damage
	if health <= 0 and dead == false:
		death()
		
func remove_positioning():
	var ground
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
	for builders in repair_list:
		builders.orders("waiting")
		builders.build()
	remove_positioning()
	faction.defence_list.remove(faction.defence_list.find(self))
	queue_free()

func positioning():
	var ground
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
		
#func repair_occupency():
#	if repair_list.size() >= repair_cap:
#		repair_full = true
		
	

	
	
	