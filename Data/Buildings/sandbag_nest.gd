extends "res://Data/Buildings/defence.gd"
var name = "Sandbag Nest"
var scrap_cost = 5
var food_cost = 0
var build_time = 5
var size = 3
var damage = 0
func AI_recount(AI):
	AI.bunkers -= 1
	
func _ready():
	occupency = 1
	total_health = 100
	health = total_health
	damage = get_node("body/machinegun_turret/body/Pig").damage
	for i in range(operators_size):
		operators.append(null)
	pass

func builder():
	return builder.get_node("three_tile_x//Build")

#func activate(op):
#	operator = op
#	set_fixed_process(true)
#func occupency():
#	if operators[0] == null:
#		full = false
#	else:
#		full = true

func op_dead(op):
	if op.get_parent() == get_node("body"):
		if operators[0] == op.myself:
			get_node("body/machinegun_turret").deactivate()
			op.get_parent().remove_child(op)
			op.defending = false
			op.placed = false
			faction.add_child(op)
			operators[0] = null
			op.set_global_pos(get_node("body/defence_pos").get_global_pos())
			op.call_deferred("set_fixed_process", true)
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
	if occupents[0].get_ref() == op:
		op.placed = true
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
