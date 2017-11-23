extends Area2D
var enter = false

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	connect("body_enter", self, "trigger")
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func trigger(collider):
	get_parent().attack()
	queue_free()
