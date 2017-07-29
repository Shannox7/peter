extends Sprite
var name = "Iron Sight"
var accuracy = rand_range(-.1, - .15)
var distance = 0
var fire_rate = rand_range(0, .001)
var stats

# extra
var stopping_power = 0
var damage = 0
var reload_speed = 0
var clip_capacity = 0
var fullauto

func _ready():
	
	#pro
	var accuracyd = round(accuracy/5 * 100)
	#con
	var fire_rated = round(-fire_rate/2 * 100)
	stats = [accuracyd, fire_rated]
	# Called every time the node is added to the scene.
	# Initialization here
	pass
