extends Area2D
var stopping_power = 3
var velocity = Vector2()
var damage = 2


var time = 1
var total_time = 1

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	connect("body_enter", self, "damage")
	connect("body_exit", self, "no_damage")
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func no_damage(collider):
	if collider.has_method("hit"):
		pass
	else:
		collider.get_parent().no_slow(50)
	if get_overlapping_bodies() == []:
		set_fixed_process(false)
		time = total_time
		
func damage(collider):
	if collider.has_method("hit"):
		collider.hit(get_parent())
	else:
		collider.get_parent().hit(get_parent())
		collider.get_parent().slow(50)
	set_fixed_process(true)

func _fixed_process(delta):
	time -= delta
	if time <= 0:
		for collider in get_overlapping_bodies():
			damage(collider)
		time = total_time
