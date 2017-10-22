extends Area2D
var set = false
var selfy
var Global
func _ready():
	Global = get_node("/root/Global")
	if set == false:
		set = true
		connect("body_enter", self, "interact")
		connect("body_exit", self, "stop_interact")
		pass
	
func interact(collider):
#	get_node("Label").show()
	if get_parent().day == true:
		collider.get_parent().comment("Start the day?")
		set_process_input(true)
	elif get_parent().dusk == true:
		collider.get_parent().comment("Begin the night?")
		set_process_input(true)
	selfy = collider.get_parent().myself
func stop_interact(collider):
#	get_node("Label").hide()
	set_process_input(false)
	selfy = null
func _input(event):
	if event.is_action_pressed("interact"):
		if get_parent().dusk:
			get_parent().night()
		elif Global.player.building != null:
			get_parent().day()


#		display map
		pass
