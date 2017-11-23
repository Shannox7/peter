extends RayCast2D
var damage = 0
var stopping_power = 0
var enemyside
var time = .25
var attacker
var velocity = Vector2(0, 0)
var drop = false
#var rotate = 45
var effect = null
var effect_multiplier = 0
func _ready():
	set_fixed_process(true)
	
func effect(collider, hit):
	hit_pierce_effect(collider, hit)
	
func _fixed_process(delta):
	colliding()
	time -= delta
	if time <= 0:
		queue_free()
func hit_pierce_effect(collider, hit):
	if hit:
		collider.hit(self)
		add_exception(collider)
func colliding():
	if is_colliding():
		if get_collider().is_in_group("inanimate"):
			effect("no_hit", false)
		elif get_collider().has_method("hit"):
			effect(get_collider(), true)
		else:
			effect(get_collider().get_parent(), true)