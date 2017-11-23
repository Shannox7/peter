extends "res://Data/Weapons/Gun Parts/Barrel/Barrel.gd"
var name = "Basic Barrel"
var accuracy = 25
var distance = -.3
var stopping_power = rand_range(0.1, 0.2)
var stats
# extra
var damage = 2
var reload_speed = 0
var fire_rate = .2
var clip_capacity = 0
var fullauto
var barrel_size = 5

var bullets_inbullets = 5

func equip(gun):
	gun.bullets_inbullets += bullets_inbullets
	gun.distance += distance
	gun.accuracy += accuracy
	gun.damage += damage
	gun.fire_rate += fire_rate
func bullet(bullet):
	var new_bullet =  attacks.get_node(str(get_parent().get_parent().type) + "/split").duplicate()
#	bullet.distance += distance
	new_bullet
	bullet = new_bullet
	return bullet
	pass
#	bullet = get_parent().b.instance().get_node("Lazer")
#	return bullet
	
func _ready():
	var accuracyd = round((accuracy/5 * 100)*-1)
	var distanced = round((distance/3 * 100) * -1)
	var stopping_powerd = round(stopping_power/10 * 100)
	stats = [accuracyd, distanced, stopping_powerd]
