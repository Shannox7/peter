extends Area2D
var stopping_power = 3
var velocity = Vector2()
var damage = 2


var time = 1
var total_time = 1
func _ready():
	connect("body_enter", self, "damage")
#	connect("area_enter", self, "damage")
#	connect("body_exit", self, "no_damage")

	pass

func no_damage(collider):
	if get_overlapping_bodies() == []:
#		set_fixed_process(false)
		time = total_time
		
func damage(collider):
	if collider.has_method("hit"):
		collider.hit(get_parent())
	elif collider.get_parent().has_method("hit"):
		collider.get_parent().hit(get_parent())
#	set_fixed_process(true)

func _fixed_process(delta):
	time -= delta
	if time <= 0:
		for collider in get_overlapping_bodies():
			damage(collider)

		time = total_time
