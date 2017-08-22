extends KinematicBody2D




#values

#nodes and vars


var orders
var head
var arm_r
var playerAnimNode
var playerArmAnimNode
var anim = ""
var animNew = ""
var armanim = ""
var armanimnew = ""



#loads
var attacks = preload("res://Attacks.tscn")


#lists
var pack = []
var headArmour = []
var bodyArmour = []
var primaryGun = []
var secondaryGun = []

var enemy = "enemies"
var side = "allies"
var sidenumber = 2
var enemynumber = 4

func _ready():
	enemy = "enemies"
	side = "allies"
	sidenumber = 2
	enemynumber = 4
		



#		if aim == true:
#			arm_r.set_pos(Vector2(5 * flip_mod, 10))


	
func fireready():
	melee = false
	if primaryGun != []:
		attack_ready = true
		fire_ready.set_wait_time(primaryGun[0].fire_rate)
		fire_ready.start()

func unequip(itemvar):
	itemvar[0].get_parent().remove_child(itemvar[0])
	itemvar[0].named = str(itemvar[0].name)
	itemvar[0].is_equipped = false
	itemvar.pop_front()
	

	

	


