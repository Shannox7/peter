extends Node2D
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
func random(part):
	var partlist = get_node(part).get_children()
	var part = partlist[round(rand_range(0, partlist.size() - 1))]
	return (partlist[0].duplicate())
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
