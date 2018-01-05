extends RigidBody2D
var damage = 5
var velocity = Vector2()
var stopping_power = 0
var time = 10

var effect = null
var effect_multiplier = 0

var poison = 0
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func start():
#	set_collision_mask_bit(1, true)
#	set_collision_mask_bit(2, true)
#	set_collision_mask_bit(0, true)
	set_mode(0)
	set_fixed_process(true)
	apply_impulse(Vector2(), Vector2(0, 10))

func _fixed_process(delta):
#	set_applied_force(Vector2(500, 10))
	time -= delta
	var velocity1 = get_linear_velocity()
	if get_colliding_bodies() != []:
		for bodies in get_colliding_bodies():
			if bodies.is_in_group("inanimate"):
				pass
			else:
				if bodies.has_method("hit"):
					bodies.hit(self)
				else:
					bodies.get_parent().hit(self)
					queue_free()
	if (abs(velocity1.x) < 5 and abs(velocity1.y) < 5) and time <= 9.5:
		queue_free()
	elif time <= 0:
		queue_free()