extends Node2D

func random():
	var gunlist = []
	gunlist = get_children()
	var randomgun = int(rand_range(0, gunlist.size() - 1))
	return (gunlist[randomgun].duplicate())

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
