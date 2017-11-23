extends Node2D
var loaded = false
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	if loaded == false:
		loaded = true
		set_fixed_process(true)
		get_node("Area2D").connect("body_enter", self, "detect")
		get_node("Area2D").connect("body_exit", self, "no_detect")
		get_node("Area2D1").connect("body_enter", self, "sight")
		get_node("Area2D1").connect("body_exit", self, "no_sight")
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func sight(item):
	if item.is_in_group("darkness"):
		item.set_opacity(.5)
	pass
func no_sight(item):
	if item.is_in_group("darkness"):
		item.set_opacity(1)
	pass

func detect(item):
	if item.is_in_group("darkness"):
		item.set_opacity(0)

func no_detect(collider):
	if collider.is_in_group("darkness"):
		collider.set_opacity(1)

func _fixed_process(delta):
	for dark in get_node("Area2D1").get_overlapping_bodies():
		dark.set_opacity(.5)
	for dark in get_node("Area2D").get_overlapping_bodies():
		dark.call_deferred('set_opacity', 0)
