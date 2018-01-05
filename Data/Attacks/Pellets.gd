extends "res://Data/Attacks/Attacks.gd"

func _ready():
	initialize()
	if visual_effect != null:
		visual_effect.set_param(0, 90 * flip_mod)
func fire():
#	get_node("Particles2D").set_color(Color(0,0,0))
	get_node("Sprite").set_modulate(Color(50,0,0))
	visual_effect.set_emitting(true)

func freeze():
#	get_node("Particles2D").set_color(Color(0,0,0))
	get_node("Sprite").set_modulate(Color(0,0,50))
	visual_effect.set_emitting(true)
func shock():
#	get_node("Particles2D").set_color(Color(0,0,0))
	get_node("Sprite").set_modulate(Color(5,5,5))
	visual_effect.set_emitting(true)

	
func effect(collider, hit):
	if hit:
		blood()
		collider.hit(self)
		queue_free()
	else:
		queue_free()
	
func _fixed_process(delta):
	distance -= delta
	velocity = Vector2(cos(get_rot()) * delta * bulletspeed * flip_mod, -sin(get_rot()) * delta * bulletspeed * flip_mod)
	if distance <= 0:
		drop = true
		fade()
	move(velocity)
	colliding()