extends "res://Data/Basic_infantry.gd"
var limbs = preload("res://Limbs.tscn")
var guns = preload("res://Guns.tscn")
#var enemies = preload("res://Enemies.tscn").instance()
var scream_delay = 5
var total_scream_delay = 5
var total_scream_time = 5
var scream_time = 5
var scream = false
var spawn = 1

var wait = true
var random = rand_range(0, 3)
var wait_time_total = 3
var wait_time = 2
var look
var travel = null
var moving = false
var climb = false
var main_point


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func wait(delta):
	random -= delta
	if random <= 0:
		wait = false
	
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
	if effect == null:
		arm_r.get_node("bicep").set_modulate(Color(1,1, 1))
		arm_r.get_node("bicep/forearm").set_modulate(Color(1,1, 1))
		arm_r.get_node("bicep/forearm/hand").set_modulate(Color(1,1, 1))
		arm_l.get_node("bicep").set_modulate(Color(1,1, 1))
		arm_l.get_node("bicep/forearm").set_modulate(Color(1,1, 1))
		arm_l.get_node("bicep/forearm/hand").set_modulate(Color(1,1, 1))
		for limb in leg_l.get_children():
			limb.set_modulate(Color(1,1, 1))
		for limb in leg_r.get_children():
			limb.set_modulate(Color(1,1, 1))
		head.get_node("head/Sprite").set_modulate(Color(1,1, 1))
		legs.set_modulate(Color(1,1, 1))
	#	leg_l.set_modulate(Color(0,0, 255))
	#	leg_r.set_modulate(Color(0,0, 255))
		waist.set_modulate(Color(1,1, 1))
	
func burning():
		arm_r.get_node("bicep").set_modulate(Color(0,0, 0))
		arm_r.get_node("bicep/forearm").set_modulate(Color(0,0, 0))
		arm_r.get_node("bicep/forearm/hand").set_modulate(Color(0,0, 0))
		arm_l.get_node("bicep").set_modulate(Color(0,0, 0))
		arm_l.get_node("bicep/forearm").set_modulate(Color(0,0, 0))
		arm_l.get_node("bicep/forearm/hand").set_modulate(Color(0,0, 0))
		for limb in leg_l.get_children():
			limb.set_modulate(Color(0,0, 0))
		for limb in leg_r.get_children():
			limb.set_modulate(Color(0,0, 0))
		head.get_node("head/Sprite").set_modulate(Color(0,0, 0))
		legs.set_modulate(Color(0,0, 0))
		waist.set_modulate(Color(0,0, 0))
	
func blue():
#	get_node("hit_timer").start()
	arm_r.get_node("bicep").set_modulate(Color(0,0, 255))
	arm_r.get_node("bicep/forearm").set_modulate(Color(0,0, 255))
	arm_r.get_node("bicep/forearm/hand").set_modulate(Color(0,0, 255))
	arm_l.get_node("bicep").set_modulate(Color(0,0, 255))
	arm_l.get_node("bicep/forearm").set_modulate(Color(0,0, 255))
	arm_l.get_node("bicep/forearm/hand").set_modulate(Color(0,0, 255))
	for limb in leg_l.get_children():
		limb.set_modulate(Color(0,0, 255))
	for limb in leg_r.get_children():
		limb.set_modulate(Color(0,0, 255))
	head.get_node("head/Sprite").set_modulate(Color(0,0, 255))
	legs.set_modulate(Color(0,0, 255))
	waist.set_modulate(Color(0,0, 255))
	
func red():
	get_node("hit_timer").start()
	if effect == null:
		arm_r.get_node("bicep").set_modulate(Color(255,0, 0))
		arm_r.get_node("bicep/forearm").set_modulate(Color(255,0, 0))
		arm_r.get_node("bicep/forearm/hand").set_modulate(Color(255,0, 0))
		arm_l.get_node("bicep").set_modulate(Color(255,0, 0))
		arm_l.get_node("bicep/forearm").set_modulate(Color(255,0, 0))
		arm_l.get_node("bicep/forearm/hand").set_modulate(Color(255,0, 0))
		for limb in leg_l.get_children():
			limb.set_modulate(Color(255,0, 0))
		for limb in leg_r.get_children():
			limb.set_modulate(Color(255,0, 0))
#		head.get_node("head/Sprite").set_modulate(Color(255,0, 0))
		legs.set_modulate(Color(255,0, 0))
		waist.set_modulate(Color(255,0, 0))

func shocking():
	arm_r.get_node("bicep").set_modulate(Color(5,5, 5))
	arm_r.get_node("bicep/forearm").set_modulate(Color(5,5, 5))
	arm_r.get_node("bicep/forearm/hand").set_modulate(Color(5,5, 5))
	arm_l.get_node("bicep").set_modulate(Color(5,5, 5))
	arm_l.get_node("bicep/forearm").set_modulate(Color(5,5, 5))
	arm_l.get_node("bicep/forearm/hand").set_modulate(Color(5,5, 5))
	for limb in leg_l.get_children():
		limb.set_modulate(Color(5,5, 5))
	for limb in leg_r.get_children():
		limb.set_modulate(Color(5,5, 5))
#	head.set_modulate(Color(5,5, 5))
	legs.set_modulate(Color(5,5, 5))
	waist.set_modulate(Color(5,5, 5))
	
func hit(collider):
#	if collider.get_global_pos().y < collider.get_global_pos().y:
#		print ("critical")
#		collider.damage = collider.damage * 2

	if collider.effect != null and effect == null:
		effect = collider.effect
		if collider.effect == "freeze":
			freeze(collider.effect_multiplier)
		elif collider.effect == "fire":
			burn(collider.effect_multiplier)
		elif collider.effect == "shock":
			shock(collider.effect_multiplier)
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
		death()
		get_node("SamplePlayer2D").play("death")
	health()

func melee_attack(m):
	var Aimrot = head.get_rot() * flip_mod
	var pos = Vector2(cos(Aimrot), -sin(Aimrot)) * flip_mod
	var spawn_point = get_node("body/head/bite").get_global_pos()
	get_node("SamplePlayer2D").play("bite")
	m = load("res://Attacks.tscn").instance().get_node("melee/Bite").duplicate()
	if flip_mod == -1:
		m.set_scale(Vector2(1 * flip_mod, 1)) 
		m.flip_mod = -1
	m.stopping_power = .5
	m.damage = 1
	get_node("AnimationPlayer").play("Bite")
	fire_ready.set_wait_time(.5)
	m.distance = .3
	m.bulletspeed = 100
	m.set_rot(Aimrot)
	m.set_collision_mask_bit(faction.enemynumber, true)
	fire_ready.start()
	m.set_global_pos(spawn_point)
	level.add_child(m)
	
func navigate(goal):
	if not moving and grounded:
		var position = get_global_pos()
		main_point = goal
		if abs(main_point.get_global_pos().y - position.y) >= 40:
			travel = null
			if main_point.get_global_pos().y + 40 > position.y:
				for drop in zone.get_node("drops").get_children():
					if drop.get_global_pos().y > position.y - 30 and drop.get_global_pos().y < position.y + 30:
						travel = drop
				for drop in zone.get_node("drops").get_children():
					if drop.get_global_pos().y > position.y - 30 and drop.get_global_pos().y < position.y + 30 and drop.get_global_pos().distance_to(position) < travel.get_global_pos().distance_to(position):
						travel = drop
			if travel != null:
				moving = true
				dropping = true
			elif main_point.get_global_pos().y - 80 < position.y:
				travel = null
				for climbs in zone.get_node("climbs").get_children():
					if (climbs.get_global_pos().y > position.y - 25 and climbs.get_global_pos().y < position.y + 25):
						travel = climbs
				for climbs in zone.get_node("climbs").get_children():
					if ((climbs.get_global_pos().y > position.y - 25 and climbs.get_global_pos().y < position.y + 25) and abs(climbs.get_global_pos().x - position.x) < abs(travel.get_global_pos().x - position.x)):
						travel = climbs
				if travel != null:
					moving = true
					climbing = true
#						if target_list.front().get_ref().get_node("body").get_global_pos().y - 50 > get_node("body").get_global_pos().y:
#							holding = false


func climbing():
	raycast.set_rot(get_angle_to(travel.get_global_pos()) - 3.14159/2)
	holding = false
	if travel.get_global_pos().distance_to(get_global_pos()) < 3:
		holding = true
		climb = true
	if velocity.y > -WALK_SPEED and climb == true:
		grounded = true
		velocity.y -= ACCELERATION
	if get_global_pos().y <= travel.get_children().back().get_global_pos().y - 10:
		velocity.y = -50
		holding = false
		climbing = false
		moving = false
		climb = false
		grounded = false
	elif main_point.get_global_pos().y > get_global_pos().y or travel.get_global_pos().y + 20 < get_global_pos().y:
		holding = false
		climbing = false
		moving = false
		climb = false
		grounded = false
func dropping():
	raycast.set_rot(get_angle_to(travel.get_global_pos()) - 3.14159/2)
	if travel.get_global_pos().distance_to(get_global_pos()) < 20:
		holding = false
		grounded = false
	if travel.get_global_pos().y + 20 < get_global_pos().y:
		dropping = false
		holding = false
		moving = false

func chase():
	if chase == false:
		chase = true
		
func scream(delta):
	holding = true
	scream_time -= delta
	spawn -= delta
	if spawn <= 0:
#		zone.reinforce()
		call_more_enemies()
		spawn = 1
	if scream_time <= 0:
		scream_time = total_scream_time
		spawn = 1
		scream = false
func call_more_enemies():
	var spawning = zone.get_node("spawns").get_children()[round(rand_range(0, zone.get_node("spawns").get_children().size() - 1))]
	var zombie = Global.enemies.get_node("Zombie_movement").duplicate()
	faction.call_deferred('add_child', zombie)
	zombie.set_global_pos(spawning.get_global_pos())
	zombie.target_list.append(target_list.front())
	zombie.chase()
	pass