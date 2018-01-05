extends Area2D
var loaded = false
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var size 

func _ready():
	if loaded == false:
		loaded = true
		connect("body_enter", self, "zone")
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func size():
	size = get_node("positions/Position2D1").get_global_pos().distance_to(get_node("positions/Position2D").get_global_pos()) + 20

func zone(collider):
	collider.get_parent().zone = self
	if collider.get_parent().is_in_group("players"):
		get_parent().get_parent().call_deferred("reinforce", get_parent())
		collider.get_parent().zone()