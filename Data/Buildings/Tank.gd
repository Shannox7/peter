extends "res://vehicles.gd"
#var Gun
#var Guns = preload("res://Guns.tscn")
#var basic_gun
var name = "Tank"
var cost = 10
var operators_size = 2

func _ready():
	total_health = 300
	WALK_SPEED = 30
	
	Gun = get_node("body/Tank_gun")
	arm_r = Gun
	primaryGun.append(Gun)
	
	faction = get_parent()
	level = get_parent().get_parent()
	for i in range(operators_size):
		operators.append(null)
	get_node("body").set_layer_mask_bit(faction.sidenumber, true)
	get_node("body").add_to_group(faction.side)
	Gun.get_node("Area2D").set_collision_mask_bit(faction.enemynumber, true)
	faction.vehicle_list.append(self)
	animNode = get_node("body/legs")
	armanimNode = get_node("AnimationPlayer") 
	raycast = get_node("body/RayCast2D")
	hold_range = hold_order * hold_range

	Gun.get_node("Area2D").connect("body_enter", self, "track")
	Gun.get_node("Area2D").connect("body_exit", self, "untrack")
	fire_ready = get_node("Attack")
	fire_ready.set_wait_time(.5)
	fire_ready.connect("timeout", self, "fireready")
	get_node("hit_timer").connect("timeout", self, "original_colour")
	orders("attack")
	health = total_health

	
func activate(op):
	operator = op
	set_fixed_process(true)
	
func deactivate():
	set_fixed_process(false)
	
func op_dead(op):
	if op.get_parent() == get_node("body"):
		if operators[0] == op:
			set_fixed_process(false)
			op.defending = false
			op.in_defence = false
			op.get_parent().remove_child(op)
			faction.add_child(op)
			op.set_fixed_process(true)
			operators[0] = null
			if operators[1] != null:
				operators[0] = operators[1]
				operators[1] = null
				get_node("body/machinegun_turret").deactivate()
				get_node("body/machinegun_turret").operator = null
				operators[0].set_pos(get_node("body/driver_pos").get_pos())
				activate(op)
			else:
				deactivate()
		elif operators[1] == op:
			get_node("body/machinegun_turret").deactivate()
			get_node("body/machinegun_turret").operator = null
			op.defending = false
			op.in_defence = false
			op.get_parent().remove_child(op)
			faction.add_child(op)
			op.set_fixed_process(true)
			operators[1] = null
	else:
		if operators[0] == op:
			operators[0] = null
			op.defending = false
			op.in_defence = false
		elif operators[1] == op:
			operators[1] = null
			op.defending = false
			op.in_defence = false
	occupency()

func add_operator(op):
	if operators[0] == null:
		operators[0] = op
	else:
		operators[1] = op
	occupency()
		
func place(op):
	op.set_fixed_process(false)
	if operators[0] == op:
		op.get_parent().remove_child(op)
		get_node("body").add_child(op)
		op.set_pos(get_node("body/driver_pos").get_pos())
		op.swap()
		op.arm_r.set_rotd(Gun.get_rotd())
		activate(op)
	elif operators[1] == op:
		op.get_parent().remove_child(op)
		get_node("body").add_child(op)
		op.set_pos(get_node("body/gunner_pos").get_pos())
		op.swap()
		op.arm_r.set_rotd(get_node("body/machinegun_turret").Gun.get_rotd())
		get_node("body/machinegun_turret").activate(op)
	op.flip(false)

func occupency():
	if operators[0] != null and operators[1] != null:
		full = true
	else:
		full = false
		
func hit(collider):
#	if collider.get_global_pos().y < collider.get_global_pos().y:
#		print ("critical")
#		collider.damage = collider.damage * 2
#	get_node("hit_timer").start()
#	red()
	health -= collider.damage
	if health <= 0 and dead == false:
		dead = true
		death()
#	health()
func die(delta):
	call_deferred("queue_free")
	
func _fixed_process(delta):
#	gravity_check(delta)
	if operators[0] == null:
		set_fixed_process(false)
	if dead == true:
		die(delta)
#	elif high_priority_list != [] or base_priority_list != [] or low_priority_list != []:
	elif high_priority_list != []:
#		track_closest(high_priority_list)
		tank_attack(high_priority_list.front())
	elif target_list != []:
#		track_closest(target_list)
		tank_attack(target_list.front())
	elif low_priority_list != []:
#		track_closest(low_priority_list)
		tank_attack(low_priority_list.front())
	elif attack:
		go_to(objective)
		if objective.side == faction.side:
			orders("attack")
			
#	grounded_check()
	flip_check()
	moving(delta)
	the_movement(delta)
#	animation()
	if level.game_over:
		set_fixed_process(false)