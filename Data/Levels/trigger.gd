extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	connect("body_enter", self, "release")
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func release(collider):
	for trap in get_parent().get_node("traps").get_children():
		trap.start()
	disconnect("body_enter", self, "release")
	pass