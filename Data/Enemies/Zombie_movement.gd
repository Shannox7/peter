extends "res://Data/Basic_infantry.gd"
var limbs = preload("res://Limbs.tscn")
var wait = true
var random = rand_range(0, 3)
var wait_time_total = 3
var wait_time = 3
func _ready():
	faction = get_parent()
	level = get_parent().get_parent()
	side()
	if not spawned:
		WALK_SPEED = 75
		spawned = true
		myself = weakref(self)
		faction.attacker_list.append(myself)
		set_fixed_process(true)
		jump_over = get_node("jump_over")
		jump_l = get_node("jump_l")
		jump_r = get_node("jump_r")
		arm_r = get_node("body/arm_r")
		arm_l = get_node("body/arm_l")
		head = get_node("body/head")
		torso = get_node("body/torso")
		legs = get_node("body/legs")
		raycast = get_node("body/direction")
	#	rayNode = get_node("body/head/cast")
		fire_ready = get_node("body/Attack")
		fire_ready.set_wait_time(.5)
		fire_ready.connect("timeout", self, "fireready")
		get_node("hit_timer").connect("timeout", self, "original_colour")
		get_node("body/Area2D").connect("body_enter", self, "track")
		get_node("body/Area2D").connect("body_exit", self, "untrack")
		health_display = get_node("body/head/health_meter/health")
		armanimNode = get_node("AnimationPlayer")
		animNode = get_node("body/legs")
		health = total_health
		health()
		orders("attack")

func melee_attack(m):
	var Aimrot = head.get_rot() * flip_mod
	var pos = Vector2(cos(Aimrot), -sin(Aimrot)) * flip_mod
	var spawn_point = get_node("body/head/bite").get_global_pos()
	
	m = load("res://Attacks.tscn").instance().get_node("Bite").duplicate()
	if flip_mod == -1:
		m.set_scale(Vector2(1 * flip_mod, 1)) 
		m.flip_mod = -1
	m.stopping_power = .5
	m.damage = 1
	armanim = "Bite"
	fire_ready.set_wait_time(.5)
	m.distance = .3
	m.bulletspeed = 100
	m.set_rot(Aimrot)
	m.set_collision_mask_bit(faction.enemynumber, true)
	fire_ready.start()
	m.set_global_pos(spawn_point)
	level.add_child(m)

func hit(collider):
#	if collider.get_global_pos().y < collider.get_global_pos().y:
#		print ("critical")
#		collider.damage = collider.damage * 2
	red()
	if hit == false:
		knockback_velocity.x = collider.velocity.x * collider.stopping_power
		knockback_velocity.y = collider.velocity.y * collider.stopping_power
		if collider.drop != true:
			var random = int(rand_range(0, 5))
			if (random == 1 and right_arm_gone == false):
				right_arm_gone = true
				dismember(arm_r)
			elif (random == 2 and left_arm_gone == false):
				left_arm_gone = true
				dismember(arm_l)
	hit = true
	health -= collider.damage
	if health <= 0 and not dead:
		dismember(head)
		death()
	health()
	
func dismember(anatomy):
	var limb = limbs.instance()
	var arm_right = limb.get_node("z_arm_r").duplicate()
	var arm_left = limb.get_node("z_arm_l").duplicate()
	var headz = limb.get_node("z_head").duplicate()
	var torsoz = limb.get_node("z_torso").duplicate()
	var new_limb
	if anatomy == arm_r:
		new_limb = arm_right
		if primaryGun != []:
			dropGun()
	elif anatomy == arm_l:
		new_limb = arm_left
	elif anatomy == head:
		new_limb = headz
	elif anatomy == torso:
		new_limb = torsoz 
	new_limb.set_global_pos(anatomy.get_global_pos())
	new_limb.set_rotd(anatomy.get_rotd())
	if flipped:
		new_limb.get_node("Sprite").set_flip_h(true)
		new_limb.flip_mod = - 1
	new_limb.knockback = knockback_velocity
	get_parent().add_child(new_limb)
	anatomy.hide()
	
func original_colour():
	hit = false
	arm_l.set_modulate(Color(1, 1, 1))
	arm_r.set_modulate(Color(1, 1, 1))
	head.set_modulate(Color(1, 1, 1))
	torso.set_modulate(Color(1, 1, 1))
	legs.set_modulate(Color(1, 1, 1))

func red():
	get_node("hit_timer").start()
	arm_l.set_modulate(Color(255,0, 0))
	arm_r.set_modulate(Color(255,0, 0))
	head.set_modulate(Color(255,0, 0))
	torso.set_modulate(Color(255,0, 0))
	legs.set_modulate(Color(255,0, 0))

func wait(delta):
	random -= delta
	if random <= 0:
		wait = false

func _fixed_process(delta):

	gravity_check(delta)
	
	if primaryGun != [] and target_list == [] and low_priority_list == [] or (primaryGun != [] and dead):
		primaryGun[0].aiming(false, faction.enemynumberval)
	
	if dead == true:
		die(delta)
	elif wait:
		holding = true
		wait(delta)
	elif retreat:
		go_to(objective)
	elif target_list != []:
		attack(target_list)
		wait_time -= delta
		if wait_time <= 0:
			track_closest(target_list)
			wait_time = wait_time_total
	elif follow:
		go_to(objective)
	elif attack:
		go_to(objective)
#		if objective.side == faction.side:
#			orders("attack")
			
	grounded_check()
	flip_check()
	moving(delta)
#	jumping(delta)
	the_movement(delta)
	knockback()
	animation()

#########################

