extends Area2D
var obstructions = []
var defence_zone = []
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	if get_parent().placed:
		set_fixed_process(false)
		queue_free()
	else:
		set_fixed_process(true)
		connect("body_enter", self, "non_buildable")
		connect("body_exit", self, "buildable")
		connect("area_enter", self, "defence_area") 
		connect("area_exit", self, "defence_area_exit") 
func non_buildable(collider):
	get_parent().placeable = false
	obstructions.append(collider)
func buildable(collider):
	obstructions.pop_front()
func defence_area(area):
	if area.is_in_group("defence_zone"):
		defence_zone.append(area)

func defence_area_exit(area):
	if area.is_in_group("defence_zone"):
		defence_zone.pop_front()
		get_parent().placeable = false
func red():
	get_parent().get_node("body").set_modulate(Color(255, 1, 1))
func original_colour():
	get_parent().get_node("body").set_modulate(Color(1, 1, 1))
	
func _fixed_process(delta):
	if obstructions == [] and get_node("RayCast2D").is_colliding() and defence_zone != []:
		get_parent().placeable = true

			

