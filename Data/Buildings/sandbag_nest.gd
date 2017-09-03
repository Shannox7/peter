extends "res://Data/Buildings/defence.gd"
var name = "Sandbag Nest"
var cost = 5
var build_time = 5
var size = 3

func AI_recount(AI):
	AI.bunkers -= 1
	
func _ready():
	operators_size = 1
	total_health = 100
	health = total_health
	for i in range(operators_size):
		operators.append(null)
	pass

func builder():
	return builder.get_node("three_tile_x//Build")

#func activate(op):
#	operator = op
#	set_fixed_process(true)
func occupency():
	if operators[0] == null:
		full = false
	else:
		full = true

func op_dead(op):
	if op.get_parent() == get_node("body"):
		if operators[0] == op.myself:
			get_node("body/machinegun_turret").deactivate()
			op.set_global_pos(get_node("body/defence_pos").get_global_pos())
			op.set_fixed_process(true)
			op.defending = false
			operators[0] = null
			op.get_parent().remove_child(op)
			faction.add_child(op)
	else:
		operators[0] = null
		op.defending = false
	occupency()

func add_operator(op):
	if operators[0] == null:
		operators[0] = op.myself
	occupency()

func place(op):
	op.set_fixed_process(false)
	if operators[0].get_ref() == op:
		op.get_parent().call_deferred("remove_child", op)
		get_node("body").call_deferred('add_child', op)
		op.set_pos(get_node("body/defence_pos").get_pos())
		op.swap()
		get_node("body/machinegun_turret").call_deferred("activate", op)
		op.flip(false)

func red():
	get_node("body 1").set_modulate(Color(255, 0, 0))
	get_node("body 2").set_modulate(Color(255, 0, 0))
	get_node("body 3").set_modulate(Color(255, 0, 0))
func original_colour():
	get_node("body 1").set_modulate(Color(1, 1, 1))
	get_node("body 2").set_modulate(Color(1, 1, 1))
	get_node("body 3").set_modulate(Color(1, 1, 1))
