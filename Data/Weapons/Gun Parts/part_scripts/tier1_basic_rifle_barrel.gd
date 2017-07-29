extends Sprite
var name = "Basic Barrel"
var accuracy = rand_range(-.1, - .15 )
var distance = rand_range(0.1, 0.15)
var stopping_power = rand_range(0.1, 0.2)
var stats
# extra
var damage = 0
var reload_speed = 0
var fire_rate = 0
var clip_capacity = 0
var fullauto

func _ready():
	var accuracyd = round((accuracy/5 * 100)*-1)
	var distanced = round((distance/3 * 100) * -1)
	var stopping_powerd = round(stopping_power/10 * 100)
	stats = [accuracyd, distanced, stopping_powerd]

