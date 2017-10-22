extends Control
var event_list = []
var start = false
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	if start == false:
		start = true
		for events in get_children():
			event_list.append(events.myself)

	# Called every time the node is added to the scene.
	# Initialization here
	pass

func turn():
	event_list.clear()
	for events in get_children():
		event_list.append(events.myself)
	pass