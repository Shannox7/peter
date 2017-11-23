extends "res://Data/Weapons/Gun Parts/Barrel/Barrel.gd"
var name = "Basic Barrel"
var accuracy = rand_range(-.1, - .15 )
var distance = .5
var stopping_power = rand_range(0.1, 0.2)
var stats
# extra
var damage = 10
var reload_speed = 0
var fire_rate = -.1
var clip_capacity = 0
var fullauto
var barrel_size = 5

func equip(gun):
	gun.distance += distance
	gun.accuracy += accuracy
	gun.damage += damage
	gun.fire_rate += fire_rate
	pass

func bullet(bullet):
	var new_bullet =  attacks.get_node(str(get_parent().get_parent().type) + "/splash").duplicate()
#	bullet.distance += distance
	bullet = new_bullet
	return bullet
#	bullet = get_parent().b.instance().get_node("Lazer")

	
func _ready():
	var accuracyd = round((accuracy/5 * 100)*-1)
	var distanced = round((distance/3 * 100) * -1)
	var stopping_powerd = round(stopping_power/10 * 100)
	stats = [accuracyd, distanced, stopping_powerd]