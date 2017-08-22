extends "res://Data/Soldiers.gd"
var Guns = preload("res://Guns.tscn")
var basic_gun
var name = "Infantry"
var cost = 10
func _ready():
	faction = get_parent()
	level = get_parent().get_parent()
	side()
	faction.attacker_list.append(self)
	set_fixed_process(true)
	set_process_input(true)
	animNode = get_node("body/legs")
	armanimNode = get_node("AnimationPlayer") 
	arm_r = get_node("body/arm_r")
	head = get_node("body/head")
	jump_over = get_node("jump_over")
	jump_l = get_node("jump_l")
	jump_r = get_node("jump_r")
	raycast = get_node("body/RayCast2D")
	hold_range = hold_order * hold_range
#	timer = get_node("Timer")
	viewarea = get_node("body/head/Area2D")
	viewarea.connect("body_enter", self, "cast")
	get_node("body/Area2D").connect("body_exit", self, "untrack")
	fire_ready = get_node("Attack")
	fire_ready.set_wait_time(.5)
	fire_ready.connect("timeout", self, "fireready")
	get_node("hit_timer").connect("timeout", self, "original_colour")
	
	basic_gun = Guns.instance().get_node("Tier_1/M14").duplicate()
	basic_gun.generate("Tier_1")
	if primaryGun == []:
		equip(basic_gun, false, "primaryGun")
		basic_gun.start()
	orders("attack")
	health = total_health
	health()
	defend()


			
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
		death()
	health()
	
func _fixed_process(delta):
	gravity_check(delta)
	
	if primaryGun != []:
		primaryGun[0].aiming(false, faction.enemynumber)
	if dead == true:
		die(delta)
	elif retreat:
		go_to(objective)
	elif target_list != []:
		attack()
	elif defending:
		defending()
	elif follow:
		go_to(objective)
	elif attack:
		go_to(objective)
		if objective.side == faction.side:
			orders("attack")
			
	grounded_check()
	flip_check()
	moving(delta)
	jumping(delta)
	the_movement(delta)
	knockback()
	animation()