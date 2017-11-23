extends "res://Data/Basic_infantry.gd"
var Guns = preload("res://Guns.tscn")
var basic_gun
var name = "Survivor"


func health():
	var head_health = get_node("body/head/health_meter/health")
	var scale = 3
	if health > 0.0:
		head_health.set_scale(Vector2(1, (health/total_health) * scale)) 
		if health/total_health > 0.25:
			head_health.set_modulate(Color(0, 255, 0))
		elif health/total_health <= 0.25:
			head_health.set_modulate(Color(255, 0, 0))
	else:
		head_health.set_scale(Vector2(1, 0))
		head_health.set_modulate(Color(255, 0, 0))


func _ready():
	faction.get_parent()
	level = get_parent().get_parent()
	side()
	if not spawned:
		WALK_SPEED_TOTAL = 150.0
		WALK_SPEED = 150.0
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
		arm_l = get_node("body/arm_l")
		head = get_node("body/head")
#		torso = get_node("body/torso")
		leg_l= get_node("body/leg_l")
		leg_r= get_node("body/leg_r")
		legs = get_node("body/legs")
		waist = get_node("body/waist")
		
		head = get_node("body/head")
		jump_over = get_node("body/jump_over")
		jump_l = get_node("jump_l")
		jump_r = get_node("jump_r")
		raycast = get_node("RayCast2D")
		basic_gun = Guns.instance().get_node("Soldier_guns/AK47").duplicate()
#		if primaryGun == []:
		equip(basic_gun, true, "primaryGun")
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
#		if defending:
#			if !objective.get_ref():
#				pass
#			elif get_pos().distance_to(objective.get_ref().get_global_pos()) <= 10:
#				holding = true
	elif occupy:
		placing()
	elif defending:
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
	if abs(velocity.x) > 5 and not holding and grounded and not is_prone:
		if not get_node("move").is_playing():
			get_node("move").play("run")
	elif not is_prone:
		get_node("move").play("idle")
	
	if abs(velocity.x) > 5 and not holding and grounded and is_prone:
		if not get_node("move").is_playing():
			get_node("move").play("prone_crawl")
	elif is_prone:
		get_node("move").play("prone_idle")

	grounded_check()
	flip_check()
	moving(delta)
	jumping(delta)
	the_movement(delta)
	knockback()
#	animation()
#	if level.game_over:
#		set_fixed_process(false)