extends Sprite
var name = "Small Clip"
var clip_capacity = int(rand_range(2, 10))
#con
var reload_speed = rand_range(-1, -.5)
var stats
# extra
var accuracy = 0
var distance = 0
var stopping_power = 0
var damage = 0
var fire_rate = 0
var fullauto

func _ready():
	#pro
	#con
	var reload_speedd = round((reload_speed/5 * 100))
	stats = [clip_capacity, reload_speedd]
	# Called every time the node is added to the scene.
	# Initialization here
	pass
