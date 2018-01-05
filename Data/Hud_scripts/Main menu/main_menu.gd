extends CanvasLayer
var Global
var listx = 0
var start


func _ready():
	get_node("Control").set_global_pos(Vector2(get_viewport().get_rect().size.x/2,get_viewport().get_rect().size.y/2))
	Global = get_node("/root/Global")
	set_process_input(true)
	select()
	pass
	
func _input(event):
	if event.is_action_pressed("select_down"):
		if listx < get_node("Control/lists").get_children().size() - 1:
			listx += 1
		else:
			listx = 0
		select()
	if event.is_action_pressed("select_up"):
		if listx > 0:
			listx -= 1
		else:
			listx = get_node("Control/lists").get_children().size() - 1
		select()
	elif event.is_action_pressed("interact"):
		press()

func select():
#	get_node("selector").show()
	get_node("selector").set_global_pos(get_node("Control/lists").get_children()[listx].get_global_pos())


func press():
	if listx == 0:
		Global.generate_area("City", self)
	elif listx == 1:
		Global.load_test(self)

