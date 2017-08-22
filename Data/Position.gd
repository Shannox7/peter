extends Position2D
var positions = []
var used_pos = []

func _ready():
	faction = get_parent()
	level = get_parent().get_parent()
	positions.append(get_node("Positions").get_children())
	for pos in positions:
		used_pos.append(false)
	set_fixed_process(true)
	pass
