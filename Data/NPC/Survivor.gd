extends "res://Data/Basic_infantry.gd"
var Guns = preload("res://Guns.tscn")
var basic_gun
var name = "Survivor"
#var cost = 10
var patrol_time = 2
var patrol_hold = false

func patrol(delta):
	reset()
	if patrol_hold:
		holding = true
	else:
		holding = false
	WALK_SPEED = 50
	patrol_time -= delta
	if patrol_time <= 0:
		patrol_time = rand_range(1, 2)
		var random = int(rand_range(1, 5))
		if random == 1:
			flip_mod *= -1
#			if flipped:
#				flipped = false
#			else:
#				flipped = true
			raycast.set_rotd(90 * flip_mod)
			orders("patrol")
		elif random == 2:
			patrol_hold = true
		elif random == 3:
			patrol_hold = false
			
			
func reset():
	arm_r.set_rotd(0)
	head.set_rotd(0)
	
func _ready():
	faction.get_parent()
	level = get_parent().get_parent()
	side()
	if not spawned:
		survivor_creator()
		spawned = true
		myself = weakref(self)
		faction.attacker_list.append(myself)
		Global.party.append(myself)
		set_fixed_process(true)
		get_node("body/Area2D").connect("body_enter", self, "track")
		get_node("body/Area2D").connect("body_exit", self, "untrack")
		fire_ready = get_node("Attack")
		fire_ready.set_wait_time(.5)
		fire_ready.connect("timeout", self, "fireready")
		get_node("hit_timer").connect("timeout", self, "original_colour")
		animNode = get_node("body/legs")
		armanimNode = get_node("AnimationPlayer") 
		arm_r = get_node("body/arm_r")
		head = get_node("body/head")
		jump_over = get_node("body/jump_over")
		jump_l = get_node("jump_l")
		jump_r = get_node("jump_r")
		raycast = get_node("RayCast2D")
		basic_gun = Guns.instance().get_node("Soldier_guns/AK47").duplicate()
#		if primaryGun == []:
		equip(basic_gun, false, "primaryGun")
#		get_node("body/Area2D").set_shape_transform(0, Matrix32( Vector2(1000, 0), Vector2(0, 1000),get_node("body").get_global_pos()))
#			basic_gun.start()
#		reset()
		health = total_health
		health()
#		call_deferred("defend")
	if building == null:
		orders("patrol")
			
func hit(collider):
#	if collider.get_global_pos().y < collider.get_global_pos().y:
#		print ("critical")
#		collider.damage = collider.damage * 2
	get_node("hit_timer").start()
	red()
	if hit == false and not placed:
		knockback_velocity.x = collider.velocity.x * collider.stopping_power
		knockback_velocity.y = collider.velocity.y * collider.stopping_power
	hit = true
	health -= collider.damage
	if health <= 0 and injured == false:
		injured = true
		injure()
	health()
	
func _fixed_process(delta):
#	holding = true
	gravity_check(delta)
			
	if primaryGun != [] and target_list == [] and low_priority_list == [] or (primaryGun != [] and dead):
		primaryGun[0].aiming(false, faction.enemynumberval)
	if injured == true:
		injured(delta)
	elif retreat:
		go_to(objective)
	elif target_list != []:
#		track_closest(target_list)
		attack(target_list)
		if defending:
			if !objective.get_ref():
				pass
			elif get_pos().distance_to(objective.get_ref().get_global_pos()) <= 10:
				objective.get_ref().place(self)
				placed = true
				holding = true

	elif occupy:
		defending()
	elif building_list != []:
#		track_closest(building_list)
		blowup_building(delta)
		
	elif low_priority_list != []:
		attack(low_priority_list)
		
	elif follow:
		go_to(objective)

	elif patrol:
		patrol(delta)
#	elif attack:
#		holding = false
#		if objective.get_parent().get_parent().side == faction.side:
#			orders("attack")
#		go_to(objective)

	grounded_check()
	flip_check()
	moving(delta)
	jumping(delta)
	the_movement(delta)
	knockback()
	animation()
#	if level.game_over:
#		set_fixed_process(false)