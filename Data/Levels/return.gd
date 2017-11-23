extends "res://doors.gd"
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	if loaded == false:
		loaded = true
		get_node("Area2D").connect("body_enter", self, "detect")
		get_node("Area2D").connect("body_exit", self, "no_detect")
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _input(event):
	if event.is_action_pressed("interact"):
		if not enemy_chase():
			get_parent().get_node("player_pos").set_global_pos(get_node("Area2D/Position2D").get_global_pos())
			get_node("/root/Global").player.get_parent().remove_child(get_node("/root/Global").player)
			get_node("/root/Global").return_from(get_parent())
		pass
		
		
		