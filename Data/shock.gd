extends Area2D
var stopping_power = 3
var velocity = Vector2()
var damage = 1
var effect = "shock"
var effect_multiplier = 1

var time = 1
var total_time = 1


# class member variables go here, for example:
# var a = 2
# var b = "textvar"
func start():
	set_collision_mask_bit(1, true)
	set_collision_mask_bit(2, true)
	get_node("Particles2D").set_emitting(true)
	set_fixed_process(true)
func stop():
	pass
	
func _ready():
	connect("body_enter", self, "damage")
#	connect("body_exit", self, "no_damage")
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func no_damage(collider):
#	if get_overlapping_bodies() == []:
#		set_fixed_process(false)
#		time = total_time
		
func damage(collider):
	if collider.has_method("hit"):
		collider.hit(self)
	else:
		collider.get_parent().hit(self)
	set_fixed_process(true)

func _fixed_process(delta):
	time -= delta
	if time <= 0:
		for collider in get_overlapping_bodies():
			damage(collider)
		time = total_time
