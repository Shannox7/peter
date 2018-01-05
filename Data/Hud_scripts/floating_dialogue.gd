extends Node2D
var time = 1
var opacity = 1
var label

func start():
	label = get_node("Label")
	set_fixed_process(true)
	pass

func reloading():
	start()
	label.set("custom_colors/font_color",Color(1,1,1))
	label.set_text("Reloading!")
	
func trade(trade):
	start()
	label.set("custom_colors/font_color",Color(1,1,0))
	label.set_text("$" + str(trade))

func ammo(ammo):
	start()
	label.set("custom_colors/font_color",Color(0,1,0))
	label.set_text("+" + str(ammo))
	
func reloaded():
	start()
	label.set("custom_colors/font_color",Color(1,1,0))
	label.set_text("Reloaded!")
	
func damage(number):
	start()
	label.set("custom_colors/font_color",Color(1,0,0))
	label.set_text(str(number))
	
func critical():
	start()
	label.set("custom_colors/font_color",Color(1,.5,0))
	label.set_text("Critical!")
	
func use(name):
	start()
	label.set("custom_colors/font_color",Color(1,1,1))
	label.set_text(str(name) + " used")

func placed(name):
	start()
	label.set("custom_colors/font_color",Color(1,1,0))
	label.set_text(str(name) + " placed")
	
func _fixed_process(delta):
	time -= delta * 2
	if time <= 1.1:
		opacity -= delta * 2
		set_opacity(opacity)
		if opacity <= 0:
			call_deferred("queue_free")
	set_pos(Vector2(get_pos().x, get_pos().y - .75))
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
