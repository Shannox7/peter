extends "res://vehicles.gd"
#var Gun
#var Guns = preload("res://Guns.tscn")
#var basic_gun
var name = "Helicopter"
var cost = 10
var operators_size = 1
var turret

func _ready():
	total_health = 20
	WALK_SPEED = 250
	ACCELERATION = 10
	GRAVITY = 300
	Gun = get_node("body/Pig")
	arm_r = Gun
	primaryGun.append(Gun)
	
	faction = get_parent()
	level = get_parent().get_parent()
	for i in range(operators_size):
		operators.append(null)
	get_node("body").set_layer_mask_bit(faction.sidenumber, true)
	get_node("body").add_to_group(faction.side)
	Gun.get_node("Area2D").set_collision_mask_bit(faction.enemynumber, true)
	myself = weakref(self)
	faction.vehicle_list.append(myself)
	animNode = get_node("body/legs")
	armanimNode = get_node("AnimationPlayer") 
	raycast = get_node("body/RayCast2D")
	hold_range = hold_order * hold_range
#	turret = get_node("body/helo_turret")
	jump_l = get_node("jump_l")
	jump_r = get_node("jump_l")
	jump_l.set_cast_to(Vector2(0, rand_range(200, 300)))
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
		if operators[0] == op.myself:
			set_fixed_process(false)
			op.get_parent().remove_child(op)
			op.defending = false
			op.in_defence = false
			faction.add_child(op)
			op.set_global_pos(get_node("body/driver_pos").get_global_pos())
			op.call_deferred("set_fixed_process", true)
			operators[0] = null
			death()
#			if operators[1] != null:
#				if !operators[1].get_ref():
#					operators[1] = null
#				elif operators[1].get_ref().get_parent() == get_node("body"):
#					operators[0] = operators[1]
#					operators[1] = null
#					turret.deactivate()
#					turret.operator = null
#					operators[0].get_ref().set_pos(get_node("body/driver_pos").get_pos())
#					activate(operators[0].get_ref())
#				else:
#					deactivate()
#		elif operators[1] == op.myself:
#			turret.deactivate()
#			turret.operator = null
#			op.defending = false
#			op.in_defence = false
#			op.get_parent().remove_child(op)
#			faction.add_child(op)
#			op.set_global_pos(get_node("body/gunner_pos").get_global_pos())
#			op.set_fixed_process(true)
#			operators[1] = null
	else:
		if operators[0] == op.myself:
			operators[0] = null
			op.defending = false
			op.in_defence = false
		elif operators[1] == op.myself:
			operators[1] = null
			op.defending = false
			op.in_defence = false
		occupency()

func add_operator(op):
	if operators[0] == null:
		operators[0] = op.myself
	else:
		operators[1] = op.myself
	occupency()

func place(op):
	op.set_fixed_process(false)
	if operators[0] == op.myself:
		op.get_parent().remove_child(op)
		get_node("body").add_child(op)
		op.set_pos(get_node("body/driver_pos").get_pos())
		op.swap()
		op.arm_r.set_rotd(Gun.get_rotd())
		operator = op
		activate(operator)
	elif operators[1] == op.myself:
		op.get_parent().remove_child(op)
		get_node("body").add_child(op)
		op.set_pos(get_node("body/gunner_pos").get_pos())
		op.swap()
		op.arm_r.set_rotd(turret.Gun.get_rotd())
		turret.activate(op)
		activate(operator)
	op.flip(false)

func occupency():
	if operators[0] != null:
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


	if dead == true:
		air_die(delta)
	else:
		gravity_check(delta)
		grounded_check()
		if high_priority_list != []:
			track_closest(high_priority_list)
			plane_attack(high_priority_list)
		elif target_list != []:
			track_closest(target_list)
			plane_attack(target_list)
		elif low_priority_list != []:
			track_closest(low_priority_list)
			plane_attack(low_priority_list)
		
		elif patrol:
			raycast.set_rot(get_angle_to(objective.get_global_pos()) - 3.14159/2)
			if get_global_pos().distance_to(objective.get_global_pos()) <= 300:
				orders("attack")
				patrol = false
		elif attack:
			raycast.set_rot(get_angle_to(objective.get_global_pos()) - 3.14159/2)
			if get_global_pos().distance_to(objective.get_global_pos()) <= 300:
				patrol()
			elif objective.get_parent().get_parent().side == faction.side:
				orders("attack")
				
		
		airborne(delta)
		flip_check()
		air_moving()
#		if turbulance_count >= 5:
#			set_rot(velocity.angle() - (3.14 / 2))
#			set_rotd(get_rotd() * flip_mod)
		the_movement(delta)
	#	animation()
	if level.game_over:
		set_fixed_process(false)