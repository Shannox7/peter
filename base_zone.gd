extends Node2D
var level
var positions = []
var myself
var side = "allies"
var red = false

var opacity = .3
var time_down = .5
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():

	# Called every time the node is added to the scene.
	# Initialization here
	pass

func init():
	myself = weakref(self)
	level = get_parent().get_parent()
	positions = get_node("Position2D").get_children()
	set_fixed_process(true)
func red():
	red = true
	get_node("Area2D/Sprite").play("red")
	get_node("Area2D/Sprite").set_self_opacity(.5)
func green():
	red = false
	get_node("Area2D/Sprite").play("green")
	get_node("Area2D/Sprite").set_self_opacity(.5)

func _fixed_process(delta):
	if red == true: 
		time_down -= delta
		if time_down <= 0:
			opacity -= delta
			get_node("Area2D/Sprite").set_self_opacity(opacity)
			if opacity <= 0:
				opacity = .5
				time_down = .5
				red = false