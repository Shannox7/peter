extends "res://Data/Builders.gd"
var name = "Engineer"
var cost = 10
func _ready():
	side()
	name = "Engineer"
	cost = 10
	WALK_SPEED = 150
	myself = weakref(self)
	faction.builder_list.append(myself)
	set_fixed_process(true)
	animNode = get_node("body/legs") 
	armanimNode = get_node("AnimationPlayer") 
	arm_r = get_node("body/arm_r")
	head = get_node("body/head")
	jump_over = get_node("jump_over")
	jump_l = get_node("jump_l")
	jump_r = get_node("jump_r")
	raycast = get_node("body/RayCast2D")
	get_node("body/Area2D").connect("body_enter", self, "track")
	get_node("body/Area2D").connect("body_exit", self, "untrack")
	get_node("hit_timer").connect("timeout", self, "original_colour")
	hold_range = hold_order * hold_range
	health = total_health
	health()
	build()



func original_colour():
	hit = false
	arm_r.set_modulate(Color(1, 1, 1))
	head.set_modulate(Color(1, 1, 1))
	get_node("body/legs").set_modulate(Color(1, 1, 1))
	
func red():
	arm_r.set_modulate(Color(255,0, 0))
	head.set_modulate(Color(255,0, 0))
	get_node("body/legs").set_modulate(Color(255,0, 0))
	
func hit(collider):
#	if collider.get_global_pos().y < collider.get_global_pos().y:
#		print ("critical")
#		collider.damage = collider.damage * 2
	get_node("hit_timer").start()
	red()
	if hit == false:
		knockback_velocity.x = collider.velocity.x * collider.stopping_power
		knockback_velocity.y = collider.velocity.y * collider.stopping_power
	hit = true
	health -= collider.damage
	get_node("body/head/health_meter/health").set_modulate(Color(255, 1, 1))
	if health <= 0 and dead == false:
		dead = true
		death()
	health()
	
func health():
	var scale = 3
	if health > 0.0:
		get_node("body/head/health_meter/health").set_scale(Vector2(1, (health/total_health) * scale)) 
		if health/total_health > 0.25:
			get_node("body/head/health_meter/health").set_modulate(Color(0, 255, 0))
		elif health/total_health <= 0.25:
			get_node("body/head/health_meter/health").set_modulate(Color(255, 0, 0))
	else:
		get_node("body/head/health_meter/health").set_scale(Vector2(1, 0))
		get_node("body/head/health_meter/health").set_modulate(Color(255, 0, 0))

	
func die(delta):
	deathTime -= delta
	if get_rotd() > -90 and get_rotd() < 90:  
		rotate(.05 * flip_mod)
		holding = true
		velocity = Vector2()
	if deathTime <= 0:
		call_deferred("queue_free")

func _fixed_process(delta):

	gravity_check(delta)
	if dead == true:
		die(delta)
	elif target_list != []:
		runaway()
	elif follow:
		go_to(objective)
	elif building:
		building(delta)
	elif repairing:
		repairing(delta)
	elif waiting:
		waiting(delta)
			
	grounded_check()
	flip_check()
	moving(delta)
	jumping(delta)
	the_movement(delta)
	knockback()
	animation()
	if level.game_over:
		set_fixed_process(false)