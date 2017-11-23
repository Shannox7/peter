extends Node2D
var detect_list = []
var loaded = false
var start = false
var area
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	
	if start == false:
		start = true
		get_node("Area2D").connect("body_enter", self, "detect")
		get_node("Area2D").connect("body_exit", self, "no_detect")
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func detect(collider):
	if not collider in detect_list:
		set_process_input(true)
		detect_list.append(collider)
func no_detect(collider):
	if collider in detect_list:
		detect_list.remove(detect_list.find(collider))
	if detect_list == []:
		set_process_input(false)
	pass

func _input(event):
	if event.is_action_pressed("interact"):
#		get_parent().get_parent().get_node("player_pos").set_global_pos(get_node("Area2D/Position2D").get_global_pos())
		get_node("/root/Global").player.get_parent().remove_child(get_node("/root/Global").player)
		get_node("/root/Global").load_level(get_parent().road, self)



