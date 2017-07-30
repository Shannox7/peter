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
var enemy_stopping_power = 0

var velocity = Vector2()
var rayNode
var raycast
var timer
#var bullet = preload("res://Bullets.tscn")
var player
var damage = 1
var attack = preload("res://Attacks.tscn")
var limbs = preload("res://Limbs.tscn")
var distance = .2
var accuracy = 1
var stopping_power = 2
var total_ammo = 5
var ammo
var EquippedGuns = []
var enemyGun

var idle = false
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

var reload
var cast = false
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
var headup = true
var wait_time

var reloading
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
	raycast = get_node("head/cast")
	timer = get_node("Timer")
	viewarea = get_node("head/ViewArea")
	viewarea.connect("body_enter", self, "cast")
	viewarea.connect("body_exit", self, "stop_cast")
	animation = get_node("arms")
	enemyAnimNode = get_node("AnimatedSprite")
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
	wait_time = rand_range(1, 5)
	timer.set_wait_time(wait_time)
	timer.connect("timeout", self, "action")
	health = total_health
#	enemyGun = get_node("arm_r/Gun")
	ammo = total_ammo
	
func equip(Gun):
	EquippedGuns.append(Gun)
	get_node("arm_r").add_child(Gun)
	enemyGun = EquippedGuns.front()
	enemyGun.set_pos(get_node("arm_r/Gun").get_pos())
	enemyGun.set_rotd(get_node("arm_r/Gun").get_rotd())
	
func action():
	var random = int(rand_range(1, 4))
	timer.set_wait_time(wait_time)
	idle = false
	if random == 1:
		idle = true
	elif random == 2:
		pass 
	elif random == 3:
		man_flip()
	
func cast(collider):
	if collider.is_in_group("players"):
		cast = true
		player = collider
func stop_cast(collider):
	if collider.is_in_group("players"):
		cast = false
		player = collider
func landed(beneath):
	grounded = true
func airborne(beneath):
	grounded = false
	
func attack_flip():
	attack_ready = true
	attack_timer.set_wait_time(enemyGun.fire_rate)
	attack_timer.start()
func dismember(anatomy):
	var limb = limbs.instance()
	var arm_right = limb.get_node("z_arm_r").duplicate()
	var arm_left = limb.get_node("z_arm_l").duplicate()
	var headz = limb.get_node("z_head").duplicate()
	var torsoz = limb.get_node("z_torso").duplicate()
	var new_limb
	if anatomy == arm_r:
		dropGun()
		new_limb = arm_right
	elif anatomy == arm_l:
		new_limb = arm_left
	elif anatomy == head:
		new_limb = headz
	elif anatomy == torso:
		new_limb = torsoz 
		
	new_limb.stopping_power = enemy_stopping_power
	new_limb.flipbullet = flipbullet
	new_limb.set_global_pos(anatomy.get_global_pos())
	new_limb.set_rotd(anatomy.get_rotd())
	if flipped:
		new_limb.get_node("Sprite").set_flip_h(true)
		new_limb.flip_mod = - 1
#	new_limb.get_parent().remove_child(new_limb)
	get_parent().get_parent().add_child(new_limb)
#	remove_child(anatomy)
#
#	print ("dismember")
	
func dropGun():
	enemyGun.get_parent().remove_child(enemyGun)
	get_parent().add_child(enemyGun)
	enemyGun.set_global_pos(get_node("arm_r/Gun").get_global_pos())
	enemyGun.unlock()
func jump():
	if grounded == true:
		velocity.y -= JUMP
#		rayNode.set_rot(get_angle_to(player.get_pos()) - 3.14159/2 * flip_mod)
		grounded = false
	
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
	set_layer_mask_bit(1, false)
	set_collision_mask_bit(1, false)
	set_layer_mask(2)
	set_collision_mask(2)

#	get_node("CollisionShape2D").set_trigger(true)
	dead = true
	get_parent().death(self)
#			print ("taking out the traaaaaaaash")
	deathTime.start()
	deathTime.connect("timeout", self, "set_free")
	if right_arm_gone == false:
		dropGun()
	
func set_free():
	set_fixed_process(false)
	queue_free()
	
func track(collider):
	tracking = true
	player = collider
#		playerPos = player.get_pos()
#		print("Spotted!")

func untrack(collider):
	if collider == player:
		tracking = false
		print("untrakc")
		
func attack():
	var Aimrot
	if right_arm_gone == false and EquippedGuns != []:
		Aimrot = arm_r.get_rot()
		var pos = Vector2(cos(Aimrot), -sin(Aimrot)) * 25 * flip_mod
		var spawn_point = get_global_pos() + pos
		for bullets in enemyGun.bullet_list.back():
	#		print(enemyGun.bullet_list.back())
	#		print("bullets: ")
	#		print(bullets)
	#		print (lists)
			if flip_mod == -1:
				bullets.get_node("Sprite").set_flip_h(true)  
				bullets.flip_mod = -1
			bullets.set_rotd(rad2deg(Aimrot) + rand_range(enemyGun.accuracy, -enemyGun.accuracy))
			bullets.set_pos(spawn_point)
			get_parent().get_parent().add_child(bullets)
	#		bi.damage = self.damage
	
#		if flip_mod == -1 and right_arm_gone == false:
#			get_node("arms").play("shootflip")
#		elif right_arm_gone == false:
#			get_node("arms").play("shoot")
		enemyGun.shoot()
		attack_ready = false
		attack_timer.set_wait_time(enemyGun.fire_rate)
		
		if enemyGun.current_clip <= 0:
			reload()
	else:
		var a = attack.instance()
		ai = a.get_node("Bite").duplicate()
		var headrot = head.get_rot()
		pos = Vector2(cos(headrot), -sin(headrot)) * flip_mod
		var spawn_point = get_global_pos() + pos
		if flip_mod == -1:
			ai.get_node("Sprite").set_flip_h(true)
			ai.flip_mod = -1
		ai.distance = distance
		#		bi.damage = self.damage
		ai.set_rot(head.get_rot())
		ai.set_pos(spawn_point)
		get_parent().add_child(ai)
		attack_ready = false
		attack_timer.set_wait_time(.5)
		attack_timer.start()
			
#	enemyGun.current_ammo = enemyGun.clip_capacity
func reload():
	attack_timer.stop()
	attack_timer.set_wait_time(enemyGun.reload_speed)
	enemyGun.reload()
	attack_timer.start()
#	reload.set_wait_time(enemyGun.reload_speed)
#	reload.start()

#func reloaded():
#	enemyGun.reload()
#	reload.stop()
#	attack_flip()
	
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
#	print("knockback_velocity: " + str(knockback_velocity)) 
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
#			print ("shot meh")

func man_flip():
	if flipped == false:
		flipped = true
		head.set_rotd(head.get_rotd() * flip_mod)
		flip()
	else:
		flipped = false
		head.set_rotd(head.get_rotd() * flip_mod)
		flip()

func flip():
	if flipped == true:
		flip_mod = -1
		get_node("AnimatedSprite").set_flip_h(flipped)
		if left_arm_gone == false:
			arm_l.set_flip_h(flipped)
			arm_l.set_pos(Vector2(5, 5))
		torso.set_flip_h(flipped)
		head.set_rotd(head.get_rotd() * flip_mod)
		head.set_flip_h(flipped)


		if right_arm_gone == false:
			enemyGun.flip(true)
			enemyGun.get_node("Sprite").set_flip_h(flipped)
			enemyGun.set_pos(Vector2(-18, 0))
			arm_r.set_flip_h(flipped)
			arm_r.set_pos(Vector2(5, 5))
	else:
		flip_mod = 1
#		head.set_rot(-head.get_rot())
		get_node("AnimatedSprite").set_flip_h(false)
		if left_arm_gone == false:
			arm_l.set_flip_h(false)
			arm_l.set_pos(Vector2(-5, 5))
		torso.set_flip_h(false)
		head.set_rotd(head.get_rotd() * flip_mod)
		head.set_flip_h(false)
		if right_arm_gone == false:
			arm_r.set_flip_h(false)
			arm_r.set_pos(Vector2(-5, 5))
			enemyGun.flip(false)
			enemyGun.get_node("Sprite").set_flip_h(false)
			enemyGun.set_pos(Vector2(18, 0))

func _fixed_process(delta):
	if velocity.y > 0.2 or velocity.y < -0.2:
		acceleration_modifier = 0.5
	else:
		acceleration_modifier = 1

	velocity.y += delta * GRAVITY
	
#	raycast.set_rotd(head.get_rotd())
	
	if dead == true:
#		print (get_rotd())
		if get_rotd() > -90 and get_rotd() < 90: 
#			print("rotation")
			rotate(.05 * flip_mod)
			anim = "idle"
#			velocity.x = kn
			move(velocity)
		else:
			pass
	else:
		if cast == true:
#
			var position = Vector2(player.get_pos().x, player.get_pos().y - player.get_pos().y)
#			
			raycast.set_cast_to(position)
#			print (raycast.get_cast_to())
#			print(player.get_pos())
#			get_angle_to(player.get_pos()) - 3.14159/2 + 90 *flip_mod
			
			if raycast.is_colliding():
#				print('i am colliding')
				if raycast.get_collider() == player:
#					print('player collision')
					tracking = true

		if tracking:
#			print (rayNode.get_rotd())
			var go_to = (player.get_global_pos())
			rayNode.set_rot(get_angle_to(go_to) - 3.14159/2)
			head.set_rot(get_angle_to(go_to) - 3.14159/2 * flip_mod)
			if right_arm_gone == false:
				arm_r.set_rotd(head.get_rotd())
#
			if rayNode.get_rotd() < -90  and flipped == false:
				flipped = true
				flip()
			elif rayNode.get_rotd() > -90 and flipped == true:
				flipped = false
				flip()

			timer.set_active(false)
			velocity.x = max(min(velocity.x + ACCELERATION * acceleration_modifier * flip_mod, RUN_SPEED), -RUN_SPEED)
			if abs(go_to.x - get_pos().x) <= 300 and right_arm_gone == false: 
				velocity.x = 0
				if attack_ready == true and enemyGun.current_clip > 0:
					attack()
			elif abs(go_to.x - get_pos().x) <= 20 and abs(go_to.y - get_pos().y) <= 25 and right_arm_gone == true:
				velocity.x = 0
				if attack_ready == true:
					attack()
			elif go_to.y - get_pos().y <= -40 and grounded == true and abs(velocity.y) < 20:
				jump()
			anim = "run"
#			armAnim = "armRun"
#patrol
		else:
			timer.set_active(true)
			velocity.x = max(min(velocity.x + ACCELERATION * acceleration_modifier * flip_mod, WALK_SPEED), -WALK_SPEED)
			anim = "run"
#			armanim	
# vision set up
		if flipped:
			viewarea.set_rotd(head.get_rotd() - 180 * flip_mod)
		else:
			viewarea.set_rotd(head.get_rotd())
		
		if idle == true:
			velocity.x = 0
#		print(head.get_rotd())
			if head.get_rotd() <= 75 and flipped == false and headup == true:
				head.rotate(-.04)
				if head.get_rotd() <= -50:
#					print ('woop')
					headup = false
				
			elif head.get_rotd() >= -75 and flipped == false and headup == false:
				head.rotate(.04)
#				print ('wpp')
				if head.get_rotd() >= 50: 
					headup = true
					
			if head.get_rotd() <= 75 and flipped == true and headup == false:
				head.rotate(-.04)
				if head.get_rotd() <= -50:
#					print ('woop')
					headup = true
				
			elif head.get_rotd() >= -75 and flipped == true and headup == true:
				head.rotate(.04)
#				print ('wpp')
				if head.get_rotd() >= 50: 
					headup = false
			
		if velocity.x < 30 and velocity.x > -30:
			anim = "idle"
		var motion = velocity * delta
		motion = move(motion + knockback_velocity)
		if (is_colliding()):
			if tracking:
				if get_collider().get_name() == "Obstacles" and abs(velocity.y) < 20:
					jump()
#		print (what.get_name())
			var n = get_collision_normal()
			motion = n.slide(motion)
			velocity = n.slide(velocity)
			move(motion)
		
		if knockback_velocity.x != 0 or knockback_velocity.y != 0:
#			print(knockback_velocity)
			knockback_velocity.x = knockback_velocity.x - ACCELERATION
			knockback_velocity.y = knockback_velocity.y + ACCELERATION
			if knockback_velocity.x < ACCELERATION:
				knockback_velocity.x = 0
			if knockback_velocity.y >= 0:
				knockback_velocity.y = 0

			
	if anim != animNew:
		animNew = anim
		enemyAnimNode.play(anim)
#		animation.play(armAnim)