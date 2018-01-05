extends Area2D
var craft = preload("res://Crafting.tscn").instance()
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
	collider.get_parent().comment("Craft?")
	set_process_input(true)
	selfy = collider.get_parent().myself
func stop_interact(collider):
	set_process_input(false)
	selfy = null
	
func _input(event):
	if event.is_action_pressed("interact"):
		var craft_dup = craft.duplicate()
		get_parent().add_child(craft_dup)
		selfy.get_ref().windows = true
		craft_dup.get_node("Craft").show_inventory(selfy.get_ref())
		set_process_input(false)