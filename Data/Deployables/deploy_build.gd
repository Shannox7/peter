extends Area2D
var obstructions = []
var defence_zone = []
var placed = false
var placeable = false
var structure
var full = false
var side
var sidenumber
var enemy
var enemynumber

func activate(building, s, sn, e, en):
	side = s
	enemy = e
	enemynumber = en
	sidenumber = sn
	structure = building
	structure.activate(s, sn, e, en)
	queue_free()
	
func _ready():
	set_fixed_process(true)
	connect("body_enter", self, "non_buildable")
	connect("body_exit", self, "buildable") 
func non_buildable(collider):
	obstructions.append(collider)
func buildable(collider):
	obstructions.pop_front()
	
func _fixed_process(delta):
	if obstructions == [] and get_node("RayCast2D").is_colliding():
		placeable = true
	else:
		placeable = false
		
#		if builders != []:
#			build_time -= delta * builder_time
#			if build_time <= built_animation_time:
#				structure.show()
#				structure.set_z(-2)
#				structure.set_pos(Vector2(structure_pos.x, structure_pos.y + build_time * 20))
#				if build_time <= 0:
#					structure.set_pos(structure_pos) 
#					structure.set_z(1)
#					close()
			
