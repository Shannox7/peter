extends Node
var player

func start():
	get_node("Control").set_global_pos(Vector2(get_viewport().get_rect().size.x/2,get_viewport().get_rect().size.y/2))
	set_process_input(true)
	get_tree().set_pause(true)

func stop():
	get_tree().set_pause(false)
	set_process_input(false)
	get_parent().remove_child(self)

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("esc"):
		get_tree().set_input_as_handled()
		stop()