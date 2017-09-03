extends "res://Data/Enemies/Zombies.gd"

func _ready():
	set_fixed_process(true)
	side("right")
	jump_over = get_node("jump_over")
	jump_l = get_node("jump_l")
	jump_r = get_node("jump_r")
	arm_r = get_node("body/arm_r")
	arm_l = get_node("body/arm_l")
	head = get_node("body/head")
	torso = get_node("body/torso")
	legs = get_node("body/AnimatedSprite")
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
	animNode = get_node("body/AnimatedSprite")
	hold_range = hold_order * hold_range
	health = total_health
	health()
	orders("attack")


func _fixed_process(delta):
	gravity_check(delta)
	
	if primaryGun != []:
		primaryGun[0].aiming(false, enemynumber)
	
	if dead == true:
		die(delta)
	elif retreat:
		go_to(objective)
	elif target_list != [] or priority_list != []:
		attack()
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

#########################

