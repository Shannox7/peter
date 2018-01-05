extends "res://Data/Attacks/melee.gd"

func _ready():
	get_node("Particles2D").set_emitting(true)
#	get_node("Particles2D").get_parent().remove_child(get_node("Particles2D"))
#	get_parent().add_child(get_node("Particles2D"))
	set_fixed_process(true)

func effect(collider, hit):
	hit_pierce_effect(collider, hit)

func _fixed_process(delta):
	colliding()
	time -= delta
	if time <= 0:
		queue_free()