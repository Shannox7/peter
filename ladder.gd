extends Area2D
var ladder_list = []
var loaded = false

func _ready():
	if loaded == false:
		loaded = true
		connect("body_enter", self, "ladder")
		connect("body_exit", self, "no_ladder")

	pass
	
func ladder(collider):
	collider.ladder = true
	set_fixed_process(true)
	ladder_list.append(collider.myself)
func no_ladder(collider):
	set_fixed_process(false)
	collider.ladder = false
	ladder_list.remove(ladder_list.find(collider.myself))
	
func _fixed_process(delta):
	for char in ladder_list:
		if !char.get_ref():
			pass
		else:
			char.get_ref().ladder = true
			