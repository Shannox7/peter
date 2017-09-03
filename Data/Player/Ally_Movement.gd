extends "res://Data/Basic_infantry.gd"
var Guns = preload("res://Guns.tscn")
var basic_gun
var name = "Infantry"
var cost = 10

func _ready():
	side()
	if not spawned:
		spawned = true
		myself = weakref(self)
		faction.attacker_list.append(myself)
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
		jump_over = get_node("jump_over")
		jump_l = get_node("jump_l")
		jump_r = get_node("jump_r")
		raycast = get_node("body/RayCast2D")
#		basic_gun = Guns.instance().get_node("Tier_1/M14").duplicate()
#		basic_gun.generate("Tier_1")
#		if primaryGun == []:
#		equip(spawn_home.get_ref().Gun.duplicate(), false, "primaryGun")
#			basic_gun.start()
		health = total_health
		health()
		call_deferred("defend")
	orders("attack")

#	prone(true)
			
func hit(collider):
#	if collider.get_global_pos().y < collider.get_global_pos().y:
#		print ("critical")
#		collider.damage = collider.damage * 2
	get_node("hit_timer").start()
	red()
	if hit == false and not in_defence:
		knockback_velocity.x = collider.velocity.x * collider.stopping_power
		knockback_velocity.y = collider.velocity.y * collider.stopping_power
	hit = true
	health -= collider.damage
	if health <= 0 and dead == false:
		dead = true
		death()
	health()
	
func _fixed_process(delta):
	gravity_check(delta)
			
	if primaryGun != []:
		primaryGun[0].aiming(false, faction.enemynumberval)
	if dead == true:
		die(delta)
	elif retreat:
		go_to(objective)
#	elif high_priority_list != [] or base_priority_list != [] or low_priority_list != []:
	elif target_list != []:
		track_closest(target_list)
		attack(target_list.front())
		if defending:
			
			if get_pos().distance_to(objective.get_global_pos()) <= 10:
				objective.place(self)
				in_defence = true
				holding = true

	elif defending:
		defending()
	elif building_list != []:
#		track_closest(building_list)
		blowup_building(delta)
	elif low_priority_list != []:
#		track_closest(low_priority_list)
		attack(low_priority_list.front())
	elif follow:
		go_to(objective)
	elif attack:
		holding = false
		if objective.get_parent().get_parent().side == faction.side:
			print("no switch")
			orders("attack")
		go_to(objective)
#		if not faction.flipped:
#			go_to(objective)
#		else:
#			go_to(objective)

	grounded_check()
	flip_check()
	moving(delta)
	jumping(delta)
	the_movement(delta)
	knockback()
	animation()
	if level.game_over:
		set_fixed_process(false)