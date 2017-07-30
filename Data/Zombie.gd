extends "res://Data/Enemy.gd"

var acceleration_modifier = 1
var knockback_velocity = Vector2(0, 0)
var knockback
var JUMP = 200
var attack_speed = 200


var worldnode
var hit = false
const GRAVITY = 300.0
var total_health = 10
var health
var arm_l
var arm_r
var head
var torso
var right_arm_gone = false
var left_arm_gone = false

var velocity = Vector2()
var rayNode
var timer
#var bullet = preload("res://Bullets.tscn")
var player
var damage = 1
var attack = preload("res://Attacks.tscn")
var limbs = preload("res://Limbs.tscn")

var flip_mod
var flipped = false
#var hit_box
var viewarea
var tracking
var grounded = false
var landing
var healthBar
var dead = false

var hitbox
var ai
var pos
var attack_ready = true
var flipbullet = 1


var anim
var enemyAnimNode
var animNew
var armAnim
var animation
var sight_pos

var health_bar_list = []
var healthpos
#create combustion awesomeness

#func init_root(playerNode):
#	player = playerNode
var attack_timer


func _ready():
	set_fixed_process(true)
	
	RUN_SPEED = 120
	WALK_SPEED = 50 
	ACCELERATION = 5
	
	arm_l = get_node("arm_l")
	arm_r = get_node("arm_r")
	head = get_node("head")
	torso = get_node("torso")
	rayNode = get_node("Vision")
	timer = get_node("Timer")
	viewarea = get_node("ViewArea")
	viewarea.connect("body_enter", self, "track")
	animation = get_node("arms")
	enemyAnimNode = get_node("AnimatedSprite")
	var wait_time = rand_range(1, 5)
	timer.set_wait_time(wait_time)
	healthBar = get_node("healthBar")
	health_bars(total_health)
	attack_timer = get_node("Attack")
	attack_timer.set_wait_time(.5)
	attack_timer.connect("timeout", self, "attack_flip")
#	attack_timer.set_active(false)
	landing = get_node("Area2D")
	landing.connect("body_enter", self, "landed")
	landing.connect("body_exit", self, "airborne")
	tracking = false
	flip_mod = 1
	timer.connect("timeout", self, "man_flip")
	health = total_health
	
func landed(beneath):
	grounded = true
func airborne(beneath):
	grounded = false
	
func attack_flip():
	attack_ready = true
		

	
func dismember(anatomy):
	var limb = limbs.instance()
	var arm_right = limb.get_node("z_arm_r").duplicate()
	var arm_left = limb.get_node("z_arm_l").duplicate()
	var headz = limb.get_node("z_head").duplicate()
	var torsoz = limb.get_node("z_torso").duplicate()
	var new_limb
	if anatomy == arm_r:
		new_limb = arm_right
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
	get_parent().get_parent().add_child(new_limb)
	remove_child(anatomy)
#
#	print ("dismember")
	

func jump():
	if grounded == true:
		velocity.y -= JUMP
		rayNode.set_rot(get_angle_to(player.get_pos()) - 3.14159/2 * flip_mod)
		grounded = false
	
func attack():
#	print ('ouch')
#	player.hurt(damage)
	armAnim = "Attack"
	var a = attack.instance()
	ai = a.get_node("Bite").duplicate()
	var headrot = head.get_rot()
	pos = Vector2(cos(headrot), -sin(headrot)) * 30 * flip_mod
	var spawn_point = get_global_pos() + pos
	if flip_mod == -1:
		ai.get_node("Sprite").set_flip_h(true)
		ai.flip_mod = -1
#		bi.damage = self.damage
	ai.set_rot(head.get_rot())
	ai.set_pos(spawn_point)
	get_parent().add_child(ai)
	attack_ready = false
	attack_timer.start()
	
func health_bars(number):
	for bar in range(number - 1):
		var new_health_bar = healthBar.duplicate()
		new_health_bar.set_pos(Vector2(healthBar.get_pos().x * -bar, healthBar.get_pos().y))
#		print (new_health_bar.get_instance_ID())
		health_bar_list.append(new_health_bar)
		call_deferred("deferred", new_health_bar)
		
func deferred(defer):
	add_child(defer)

func death():
#	print ("started at the bottom")
	var deathTime = get_node("death")
	deathTime.set_wait_time(1)
	deathTime.start()
	deathTime.connect("timeout", self, "set_free")
	set_layer_mask(1)
#	get_node("CollisionShape2D").set_trigger(true)
	dead = true
	
func set_free():
	set_fixed_process(false)
	queue_free()
	
#func death():
#	set_fixed_process(false)
#	queue_free()




func track(collider):
	if collider.get_name() == "Peter":
		tracking = true
		player = collider
#		playerPos = player.get_pos()
#		print("Spotted!")


func untrack(collider):
	if collider == player:
		tracking = false
		print("untrakc")	

func hit(collider):
	if collider.get_global_pos().y < collider.get_global_pos().y:
		print ("critical")
		collider.damage = collider.damage * 2

#if attack.get_name() == "Bullet":
#	animation	
#	print(dam)
#	bullethole.duplicate()
#	add_child(bullethole)
#	if flip_effect == true:
#		bullethole.set_flip_h(true)
#		flipbullet = -1
#	bullethole.set_global_pos(Vector2(position.x + 5 * flipbullet, position.y))
#	bullethole.set_z(2)

	var random = int(rand_range(0, 5))
	if (random == 1 and right_arm_gone == false):
		right_arm_gone = true
		dismember(arm_r)
		
	elif (random == 2 and left_arm_gone == false):
		left_arm_gone = true
		dismember(arm_l)
	knockback_velocity.x = collider.velocity.x * collider.stopping_power
	knockback_velocity.y = collider.velocity.y * collider.stopping_power
#	print("bullet_velocity: " + str(collider.velocity)) 
	if dead == false:
		for hits in range(collider.damage):
#			print(health)
			health_bar_list[health - 2].play("health_empty")
			health -= 1
		if health <= 0 and dead == false:
			healthBar.play("health_empty")
#			dismember(head)
#			dismember(torso)
			death()
#		print ("shot meh")
func man_flip():
	if flipped == false:
		flipped = true
		flip()
	else:
		flipped = false
		flip()

func flip():
	if flipped == true:
		flip_mod = -1
		get_node("AnimatedSprite").set_flip_h(flipped)
		arm_l.set_flip_h(flipped)
		arm_l.set_pos(Vector2(5, 5))
		torso.set_flip_h(flipped)
		head.set_flip_h(flipped)
		arm_r.set_flip_h(flipped)
		arm_r.set_pos(Vector2(5, 5))
	else:
		flip_mod = 1
#		head.set_rot(-head.get_rot())
		get_node("AnimatedSprite").set_flip_h(false)
		arm_l.set_flip_h(false)
		arm_l.set_pos(Vector2(-5, 5))
		torso.set_flip_h(false)
		head.set_flip_h(false)
		arm_r.set_flip_h(false)
		arm_r.set_pos(Vector2(-5, 5))

func _fixed_process(delta):
	if velocity.y > 0.2 or velocity.y < -0.2:
		acceleration_modifier = 0.5
	else:
		acceleration_modifier = 1

	velocity.y += delta * GRAVITY
	
	if dead == true:
#		print (get_rotd())
		if get_rotd() > -90 and get_rotd() < 90: 
#			print("rotation")
			rotate(.05 * flip_mod)
			velocity.x = knockback_velocity.x
			anim = "idle"
#			velocity.x = kn
			move(velocity)
		else:
			pass
	else:
			

		
#		arm_r.move_local_y(velocity.y)
#		destroy(arm_l)
#		var motion = velocity * delta
#		motion = move(motion)
#		arm_l.move_local_y()

		if tracking:
#			print (rayNode.get_rotd())
			var go_to = (player.get_pos())
			rayNode.set_rot(get_angle_to(go_to) - 3.14159/2)
			head.set_rot(get_angle_to(go_to) - 3.14159/2 * flip_mod)

#
		
			if rayNode.get_rotd() < -90  and flipped == false:
				flipped = true
				flip()
			elif rayNode.get_rotd() > -90 and flipped == true:
				flipped = false
				flip()

			timer.set_active(false)
			velocity.x = max(min(velocity.x + ACCELERATION * acceleration_modifier * flip_mod, RUN_SPEED), -RUN_SPEED)

			if go_to.y - get_pos().y <= -100 and grounded == true:
				jump() 
			anim = "run"
			armAnim = "armRun"
#		print (go_to.x - get_pos().x)
			if go_to.x - get_pos().x <= 30 and attack_ready == true and flipped == false: 
				attack()
			elif go_to.x - get_pos().x >= -30 and attack_ready == true and flipped:
				attack()
#patrol
		else:
			timer.set_active(true)
			velocity.x = max(min(velocity.x + ACCELERATION * acceleration_modifier * flip_mod, WALK_SPEED), -WALK_SPEED)
			anim = "run"
			armAnim = "armRun"
		


#flip

			
# vision set up

		if flipped:
			viewarea.set_rotd(head.get_rotd() - 180 * flip_mod)
		else:
			viewarea.set_rotd(head.get_rotd())

		if velocity.x < 30 and velocity.x > -30:
			anim = "idle"
		
# move

		
#		velocity.x = 0
#		if abs(knockback_velocity.x) > 0:
#			print("VELOCITY: " + str(velocity))
#			print("KNOCKBACK VELOCITY: " + str(knockback_velocity))
#		velocity += knockback_velocity

		
#animations

			
#move 

#		if knockback_velocity.x != 0 or knockback_velocity.y != 0:
#			move(knockback_velocity)
#			knockback_velocity.x = knockback_velocity.x - ACCELERATION * flip_mod
#!			knockback_velocity.y = knockback_velocity.y + ACCELERATION
#			if abs(knockback_velocity.x) < ACCELERATION:
#				knockback_velocity.x = 0
#			if abs(knockback_velocity.y) < ACCELERATION:
#				knockback_velocity.y = 0

#		else:
		var motion = velocity * delta
		motion = move(motion)
		if (is_colliding()):
			if tracking:
				if get_collider().get_name() == "Obstacles":
					jump()
#				print (what.get_name())
			var n = get_collision_normal()
			motion = n.slide(motion)
			velocity = n.slide(velocity)
			move(motion)
			
	if anim != animNew:
		animNew = anim
		enemyAnimNode.play(anim)
		animation.play(armAnim)