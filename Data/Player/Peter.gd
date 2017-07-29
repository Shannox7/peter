extends KinematicBody2D

const FLOOR_ANGLE_TOLERANCE = 46
export var WALK_SPEED = 150
export var PRONE_SPEED = 60
export var CROUCH_SPEED = 100
export var ACCELERATION = 20
export var DECCELERATION = 10
export var acceleration_modifier = 1
export var AIMSPEED = .05
var place = false
#slopes V
const SLIDE_STOP_VELOCITY = 1.0 # One pixel per second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # One pixel
var on_air_time = 100
const STOP_FORCE = 1300
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 150
var pack = []
var utility = [[],[],[],[],[],[],[],[]]
var knockback_velocity = Vector2()
var total_health = 50
var current_health = 50
var armour = 0
var total_ammo = 0
var current_ammo = 0
var health
#var health_bar_list = []
#var healthBar
var healthpos
var flip_mod = 1
var storedpower
const IDLE_SPEED = 10
const GRAVITY = 600.0
var JUMP = Vector2(0, 250)
var smalljump = Vector2(0, 200)

var aim = false
var velocity = Vector2()
var RayNode
var HeadDirection
var ArmDirection
var playerHead
var playerArm
var playerGun = []
var secondaryGun = []
var playerAnimNode
var playerArmAnimNode
var anim = ""
var animNew = ""
var armanim = ""
var armanimnew = ""

var is_crouch = false
var is_prone = false

var bullet = preload("res://PlayerAttacks.tscn")
var deployables = preload("res://Deployables.tscn")
var allies = preload("res://Allies.tscn")
var i = preload("res://Inventory_hud.tscn")
var I
var weapon = ""

#guns and bullets
var headArmour = []
var bodyArmour = []
var bullet_list = []
var pos
var stopping_power = 1
var damage = 1
var switched = false

var selected
var selected_display
var selectednumber
var landing
var grounded = false
var reload
var reloading = false
var fire_ready
var fire = false
var jump
var jumping
var ally_list = []
var inventory = false
var hold = false
var deny
func _ready():
	set_fixed_process(true)
	set_process_input(true)
	RayNode = get_node("Direction")
	playerAnimNode = get_node("AnimatedSprite")
	playerArmAnimNode = get_node("Arm")
	playerHead= get_node("Head")
	playerArm= get_node("Arm")
	landing = get_node("AnimatedSprite/Area2D")
	landing.connect("body_enter", self, "landed")
	landing.connect("body_exit", self, "airborne")
	reload = get_node("reload")
	reload.connect("timeout", self, "reloaded")
	fire_ready = get_node("fire_ready")
	fire_ready.connect("timeout", self, "fireready")
#	healthBar = get_node("healthbar")
	get_parent().health_bars(total_health)
	health = total_health
	storedpower = smalljump
#	add_collision_exception_with(get_node("Head"))
	I = i.instance()
	var machinegun_turret = deployables.instance().get_node("machinegun_turret").duplicate()
	pack.append(machinegun_turret)
	var mine = deployables.instance().get_node("mine")
	pack.append(machinegun_turret.duplicate())
	pack.append(mine.duplicate())
	mine.deactivate()
	machinegun_turret.deactivate()
#	utility = [[],[],[],[],[machinegun_turret],[],[],[]]
func fireready():
	if playerGun != []:
		fire = true
		fire_ready.set_wait_time(playerGun[0].fire_rate)
		fire_ready.start()
#fun unequip(item):
func unequip(itemvar):
	itemvar[0].get_parent().remove_child(itemvar[0])
	itemvar[0].named = str(itemvar[0].name)
	itemvar.pop_front()

	
func equip(item, pickedup, slot):
	item.named = ("-E- " + str(item.name))
	if item.is_in_group("weapons") and slot == "playerGun":
		if playerGun != [] and secondaryGun != []:
			get_parent().clear_ammo()
			unequip(playerGun)
#			playerGun[0].get_parent().remove_child(playerGun[0])
			if pickedup:
				pack.append(item)
			get_node("Arm").add_child(item)
#			playerGun.pop_back()
			playerGun.append(item)
		elif playerGun != [] and secondaryGun == []:
			playerGun[0].get_parent().remove_child(playerGun[0])
			get_node("AnimatedSprite").add_child(playerGun[0])
			get_node("Arm").add_child(item)
			if pickedup:
				pack.append(item)
			playerGun.append(item)
			secondaryGun.append(playerGun[0])
			playerGun.pop_front()
		else:
			if pickedup:
				pack.append(item)
			playerGun.append(item)
			get_node("Arm").add_child(item)
		if playerGun != []:
			playerGun[0].set_pos(get_node("Arm/Gun").get_pos())
			playerGun[0].set_rotd(get_node("Arm/Gun").get_rotd())
		if secondaryGun != []:
			secondaryGun[0].set_pos(get_node("AnimatedSprite/secondaryEquip").get_pos())
			secondaryGun[0].set_rot(get_node("AnimatedSprite/secondaryEquip").get_rot())
		update_hud()
		get_parent().clear_ammo()
		get_parent().ammo(self)
	elif item.is_in_group("weapons") and slot == "secondaryGun":
		if secondaryGun != []:
#			secondaryGun[0].get_parent().remove_child(secondaryGun[0])
#			secondaryGun.pop_front()
			unequip(secondaryGun)
		secondaryGun.append(item)
		if pickedup:
			pack.append(item)
		secondaryGun[0].set_pos(get_node("AnimatedSprite/secondaryEquip").get_pos())
		secondaryGun[0].set_rotd(get_node("AnimatedSprite/secondaryEquip").get_rotd())
		get_node("AnimatedSprite").add_child(secondaryGun[0])
	elif item.is_in_group("armour"):
		if item.is_in_group("head"):
			if headArmour != []:
#				unequip(item, "playerHead")
				headArmour[0].get_parent().remove_child(headArmour[0])
				headArmour[0].unequip(self)
				headArmour.pop_front()
				
			if pickedup:
				pack.append(item)
			headArmour.append(item)
			get_node("Head").add_child(item)
			item.set_pos(Vector2(get_node("Head").get_pos().x, -4))
			item.set_rot(get_node("Head").get_rot())
			headArmour[0].equip(self)
			get_parent().health_bars(total_health)
		elif item.is_in_group("body"):
			if bodyArmour != []:
#				unequip(item, "playerHead")
				bodyArmour[0].get_parent().remove_child(bodyArmour[0])
				bodyArmour[0].unequip(self)
				bodyArmour.pop_front()
			if pickedup:
				pack.append(item)
			bodyArmour.append(item)
			get_node("AnimatedSprite").add_child(item)
			item.set_pos(Vector2(get_node("AnimatedSprite").get_pos().x, -4))
			item.set_rot(get_node("AnimatedSprite").get_rot())
			bodyArmour[0].equip(self)
			get_parent().health_bars(total_health)
	for items in pack:
		print (items.get_name())
func fire():
	fire = false
	fire_ready.stop()
	get_parent().shoot(self)
	var Aimrot = playerArm.get_rot() +  get_rot()
	var pos = Vector2(cos(Aimrot), -sin(Aimrot)) * 30 * flip_mod
	var spawn_point = get_global_pos() + pos 
#	if playerArm.get_rotd() >= -20 and playerArm.get_rotd() <= 20:
#		print (playerArm.get_rotd())
#		spawn_point += Vector2(0, 5)
#	elif playerArm.get_rotd() <= 90 and playerArm.get_rotd() > 20:
#		if flip_mod == 1:
#			spawn_point += Vector2(0, 2)
#		else:
#			spawn_point += Vector2(0, 7)
#		print (playerArm.get_rotd())
#	elif playerArm.get_rotd() >= -90 and playerArm.get_rotd() < -20:
#		if flip_mod == 1:
#			spawn_point += Vector2(0, 7)
#		else:
#			spawn_point += Vector2(0, 2)
#	if is_prone == true:
#		spawn_point += Vector2(8 * flip_mod, 10)
#	elif is_crouch == true:
#		spawn_point += Vector2(0, 5)
		
	if flip_mod == -1:
		playerGun[0].bullet_list.back().get_node("Sprite").set_flip_h(true)  
		playerGun[0].bullet_list.back().flip_mod = -1
	playerGun[0].bullet_list.back().set_rot(Aimrot)
	playerGun[0].bullet_list.back().set_pos(spawn_point)
	get_parent().add_child(playerGun[0].bullet_list.back())
#	if flip_mod == 1:
#		get_node("animation").play("animation")
#	else:
#		get_node("animation").play("flipanimation")
	playerGun[0].shoot()
	if aim == true:
		armanim = "aim_shoot"
	else:
		armanim = "shoot"
#	get_node("Arm").play("shoot")
#	bullet_list = playerGun.bullet_list
	fire_ready.set_wait_time(playerGun[0].fire_rate)
	fire_ready.start()
#	print (fire_ready.get_wait_time())
#	print (fire_ready.get_time_left())
	if playerGun[0].current_clip <= 0 and playerGun[0].current_ammo > 0:
		reload()
		
func reload():
	reloading = true
	fire_ready.stop()
	reload.set_wait_time(playerGun[0].reload_speed)
	reload.start()
	

func reloaded():
	playerGun[0].reload()
	get_parent().clear_ammo()
	get_parent().ammo(self)
	reload.stop()
	fireready()
	reloading = false
	update_hud()
	
func update_hud():
	if playerGun != []:
		total_ammo = playerGun[0].ammo_capacity
		current_ammo = playerGun[0].current_ammo
		bullet_list = playerGun[0].bullet_list
	else:
		total_ammo = 0
		current_ammo = 0
		bullet_list = []
	get_parent().update_hud()
	
func selected(number):
#	print(utility)
	if utility[number] != []:
		selectednumber = number
		if selected_display != null:
			selected_display.queue_free()
			selected_display = null
		selected_display = utility[number][0].duplicate()
		selected_display.deactivate()
		get_parent().update_selected(selected_display)
		selected = utility[number][0]
	else:
		selected = null

func stop_reload():
	reload.set_wait_time(playerGun[0].reload_speed)
	reload.stop()
#	reload.disconnect("timeout", self, "reloaded")
	fire_ready.set_wait_time(playerGun[0].fire_rate)
	fire_ready.start()
	reloading = false

func landed(beneath):
	grounded = true
func airborne(beneath):
	grounded = false

func _input(event):
	if event.is_action_pressed("inventory"):
		if inventory == false:
			I.get_node("inventory").set_global_pos(get_parent().get_parent().get_rect().size / 2)
			get_parent().get_parent().add_child(I)
#			print(I.get_node("inventory").get_pos())
			I.get_node("inventory").show_inventory(self)
			inventory = true
		else:
			I.get_node("inventory").remove_inventory(self)
			I.get_parent().remove_child(I)
			inventory = false
		
	if event.is_action_pressed("hold"):
		for allies in ally_list:
			allies.hold = hold
		hold = !hold
	if event.is_action_pressed("select_left"):
		selected(0)
	elif event.is_action_pressed("select_up"):
		selected(2)
	elif event.is_action_pressed("select_right"):
		selected(4)
	elif event.is_action_pressed("select_down"):
		selected(6)
	if event.is_action_pressed("place") and place == false:
		if selected != null:
#		var machinegun_turret = deployables.instance().get_node("machinegun_turret")
#		var mine = deployables.instance().get_node("mine")
#		deployable = machinegun_turret
#			selected.get_parent().remove_child(selected)
			playerArm.add_child(selected)
			selected.deactivate()
			selected.set_pos(Vector2(playerArm.get_pos().x + 100, playerArm.get_pos().y)  * flip_mod)
			place = true
		
	elif event.is_action_pressed("place") and place == true:
		if selected.placeable == true:
#			print ("i collide")
			var dummypos = selected.get_global_pos()
#			var dummyrot = deployable.get_rot()

			selected.get_parent().remove_child(selected)
			selected.set_pos(dummypos)
			selected.set_rot(0)

			get_parent().get_parent().add_child(selected)
			selected.activate()
			
			selected = null
			if selected_display != null:
				selected_display.queue_free()
				selected_display = null
#			I.get_node("inventory").utility_display[selectednumber].remove(0)
#			utility[selectednumber].remove(0)
			I.get_node("inventory").remove_item(selectednumber)
			update_hud()
			place = false
		
	if event.is_action_pressed("reload") and playerGun != []:
		if reloading == false and playerGun[0].current_clip < playerGun[0].clip_capacity:
			reload()
	
	if event.is_action_pressed("recruit"):
		var ally = allies.instance().get_node("Soldier")
		ally.duplicate()
		ally.get_parent().remove_child(ally)
		ally.set_pos(Vector2(get_pos().x - 100 * flip_mod, get_pos().y))
		ally.owner = self
		get_parent().add_child(ally)
		ally_list.append(ally)
		
	if event.is_action_pressed("switch") and (playerGun != [] or secondaryGun != []):
		if reloading == true:
			stop_reload()
		if playerGun != [] and secondaryGun != []:
			secondaryGun.append(playerGun[0])
			playerGun.append(secondaryGun[0])
			secondaryGun.pop_front()
			playerGun.pop_front()
		elif playerGun == [] and secondaryGun !=[]:
			playerGun.append(secondaryGun[0])
			secondaryGun.pop_front()
		elif playerGun != [] and secondaryGun == []:
			secondaryGun.append(playerGun[0])
			playerGun.pop_front()
		if playerGun != []:
			playerGun[0].get_parent().remove_child(playerGun[0])
			playerGun[0].set_pos(get_node("Arm/Gun").get_pos())
			playerGun[0].set_rotd(get_node("Arm/Gun").get_rotd())
			get_node("Arm").add_child(playerGun[0])
			bullet_list = playerGun[0].bullet_list
		if secondaryGun != []:
			secondaryGun[0].get_parent().remove_child(secondaryGun[0])
			secondaryGun[0].set_pos(get_node("AnimatedSprite/secondaryEquip").get_pos())
			secondaryGun[0].set_rotd(get_node("AnimatedSprite/secondaryEquip").get_rotd())
			get_node("AnimatedSprite").add_child(secondaryGun[0])
		get_parent().clear_ammo()
		update_hud()
		get_parent().ammo(self)

	if event.is_action_pressed("fire") and playerGun != []: 
		if fire == true and playerGun[0].current_ammo > 0 and playerGun[0].current_clip > 0 and playerGun[0].fullauto == false:
			fire()
	elif event.is_action_pressed("fire") and playerGun != []: 
		if fire == true and playerGun[0].current_clip == 0 and playerGun.current_ammo > 0:
			print ("click")
			print ("click")
			reload()
	if event.is_action_pressed("ui_down"):
		is_prone = true
		anim = "prone_idle_r"
#		get_node("standing").set_trigger(true)
#		get_node("prone").set_trigger(false)

	if event.is_action_pressed("ui_up"):
		if is_prone == true:
			set_global_pos(Vector2(get_pos().x, get_pos().y -10))
			is_prone = false
			anim = "crouch_idle_r"
#			get_node("prone").set_trigger(true)
#			get_node("standing").set_trigger(false)


		else:
			jumping = true
	if jumping == true and (grounded == true or velocity.y <= .05 and velocity.y >= -.05) and event.is_action_released("ui_up"):
#		print('are we flying yet?')
		velocity.y -= storedpower.y
		storedpower = smalljump
		jumping = false
#		grounded = false
	elif event.is_action_released("ui_up"):
		storedpower = smalljump
		jumping = false
#		grounded = false
		
func hit(collider):
	if collider.get_global_pos().y < collider.get_global_pos().y:
		print ("critical")
		collider.damage = collider.damage * 2

	knockback_velocity.x = collider.velocity.x * collider.stopping_power
	knockback_velocity.y = collider.velocity.y * collider.stopping_power
#	print("bullet_velocity: " + str(collider.velocity)) 
#	if dead == false:
#		pasds
	get_parent().hit(self, collider.damage)

func deferred(defer):
	add_child(defer)
	
func _fixed_process(delta):
	
	if jumping == true and storedpower.y <= JUMP.y and Input.is_action_pressed("ui_up"):
		storedpower.y += 10
	elif storedpower.y >= JUMP.y and grounded:
		velocity.y -= JUMP.y
		storedpower = smalljump
		jumping = false
#	JUMP = Vector2(cos(get_rot()) * delta * flip_mod, -sin(get_rot()) * delta * JUMP.y * flip_mod)
#	storedpower = Vector2(cos(get_rot()) * delta * flip_mod, -sin(get_rot()) * delta * storedpower.y * flip_mod)
	 
	
	if velocity.y > 0.2 or velocity.y < -0.2 and (grounded == false):
		acceleration_modifier = 0.5
	else:
		acceleration_modifier = 1
	var force = Vector2(0, GRAVITY)
#	velocity.y += delta * GRAVITY
	
	if Input.is_action_pressed("fire") and playerGun != []: 
		if fire == true and playerGun[0].fullauto == true and playerGun[0].current_clip > 0:
			fire()
		
	var stop = true
	if Input.is_action_pressed("ui_left"):
		stop = false
		if flip_mod == 1:
#			flip()
			playerArm.set_rot(-playerArm.get_rot())
			playerHead.set_rot(-playerHead.get_rot())
		flip_mod = -1
		RayNode.set_rotd(-90)
		if is_prone != true:
			velocity.x = max(min(velocity.x - ACCELERATION * acceleration_modifier, -WALK_SPEED), -WALK_SPEED)
		elif is_prone == true and grounded == false:
			velocity.x = max(min(velocity.x - ACCELERATION * acceleration_modifier, -WALK_SPEED), -WALK_SPEED)
		elif is_prone == true:
			velocity.x = max(min(velocity.x - ACCELERATION * acceleration_modifier, -PRONE_SPEED), -PRONE_SPEED)
#		if (velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED):
#			force.x -= WALK_FORCE
#			stop = false

	elif Input.is_action_pressed("ui_right"):
		stop = false
		if flip_mod == -1:
		#	flip()
			playerArm.set_rot(-playerArm.get_rot())
			playerHead.set_rot(-playerHead.get_rot())
		flip_mod = 1
		RayNode.set_rotd(90)
		if is_prone != true:
			velocity.x = max(min(velocity.x + ACCELERATION * acceleration_modifier, WALK_SPEED), -WALK_SPEED)
		elif is_prone == true:
			velocity.x = min(velocity.x + ACCELERATION * acceleration_modifier, PRONE_SPEED)
		
		if (velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED):
			force.x += WALK_FORCE
			
	if Input.is_action_pressed("ui_lookup") and playerHead.get_rotd() <= 90 and RayNode.get_rotd() == 90:
		playerHead.rotate(AIMSPEED)
	elif Input.is_action_pressed("ui_lookup") and playerHead.get_rotd() >= -90 and RayNode.get_rotd() == -90:
		playerHead.rotate(-AIMSPEED)
		
	if Input.is_action_pressed("ui_lookdown") and playerHead.get_rotd() > -90 and RayNode.get_rotd() == 90:
		playerHead.rotate(-AIMSPEED)
	elif Input.is_action_pressed("ui_lookdown") and playerHead.get_rotd() < 90 and RayNode.get_rotd() == -90:
		playerHead.rotate(AIMSPEED)
				
	if Input.is_action_pressed("ui_lookup") and playerArm.get_rotd() <= 90 and RayNode.get_rotd() == 90:
		playerArm.rotate(AIMSPEED)
	elif Input.is_action_pressed("ui_lookup") and playerArm.get_rotd() >= -90 and RayNode.get_rotd() == -90:
		playerArm.rotate(-AIMSPEED)

	if Input.is_action_pressed("ui_lookdown") and playerArm.get_rotd() >= -90 and RayNode.get_rotd() == 90:
		playerArm.rotate(-AIMSPEED)

	elif Input.is_action_pressed("ui_lookdown") and playerArm.get_rotd() <= 90 and RayNode.get_rotd() == -90:
		playerArm.rotate(AIMSPEED)
	
	if Input.is_action_pressed("ui_ctrl"):
		armanim = "aim"
		aim = true
		AIMSPEED = .01
	else:
		AIMSPEED = .05
		aim = false
#move collision		
	
	if RayNode.get_rotd() == -90:
		playerAnimNode.set_flip_h(true)
		playerHead.set_flip_h(true)
		playerArm.set_flip_h(true)
		if headArmour != []:
			headArmour[0].get_node("Sprite").set_flip_h(true)
		if bodyArmour != []:
			bodyArmour[0].get_node("Sprite").set_flip_h(true)
		if playerGun != []:
			playerGun[0].flip(true)
		if secondaryGun != []:
			secondaryGun[0].flip(true)
	else:
		playerAnimNode.set_flip_h(false)
		playerHead.set_flip_h(false)
		playerArm.set_flip_h(false)
		if headArmour != []:
			headArmour[0].get_node("Sprite").set_flip_h(false)
		if bodyArmour != []:
			bodyArmour[0].get_node("Sprite").set_flip_h(false)
		if playerGun != []:
			playerGun[0].flip(false)
		if secondaryGun != []:
			secondaryGun[0].flip(false)
			
	if is_prone != true:
		playerHead.set_pos(Vector2(3 * flip_mod, -13))
		get_node("AnimatedSprite").set_pos(Vector2(3 * flip_mod, 4))
		if headArmour != []:
			headArmour[0].set_pos(Vector2(0 , -4))
		if bodyArmour != []:
			bodyArmour[0].set_rotd(0)
			bodyArmour[0].set_pos(Vector2(0, -4))
		if playerGun != []:
			playerGun[0].set_pos(Vector2(get_node("Arm/Gun").get_pos().x * flip_mod, 0))
		if secondaryGun != []:
			secondaryGun[0].set_pos(Vector2(get_node("AnimatedSprite/secondaryEquip").get_pos().x * flip_mod, get_node("AnimatedSprite/secondaryEquip").get_pos().y))
			secondaryGun[0].set_rotd(-90 * flip_mod)
#			if flip_mod == -1:
#				secondaryGun.set_pos(Vector2(18, 0))
	elif is_prone == true:
		get_node("AnimatedSprite").set_pos(Vector2(-4 * flip_mod, -2))
		playerHead.set_pos(Vector2(12 * flip_mod, -6))
#		playerArm.set_offset(Vector2(7 * flip_mod, 2))
#		playerArm.set_pos(Vector2(4 * flip_mod, 2))
		if headArmour != []:
			headArmour[0].set_pos(Vector2(0, -4))
		if bodyArmour != []:
			bodyArmour[0].set_rotd(-90 * flip_mod)
			bodyArmour[0].set_pos(Vector2(2, 0))
		if playerGun != []:
			playerGun[0].set_pos(Vector2(15 * flip_mod, 0))
		if secondaryGun != []:
			secondaryGun[0].set_rotd(180 * flip_mod)
			secondaryGun[0].set_pos(Vector2(get_node("AnimatedSprite/secondaryEquip").get_pos().x + 7, get_node("AnimatedSprite/secondaryEquip").get_pos().y + 3))
		if aim == true:
			playerArm.set_pos(Vector2(5 * flip_mod, 10))
#			playerGun.set_pos(Vector2(15 * flip_mod, 0)
	get_node("headcollision").set_pos(playerHead.get_pos())
		
	if place == true:
		selected.set_pos(Vector2(playerArm.get_pos().x + 100, playerArm.get_pos().y)  * flip_mod)
		selected.set_rot(get_rot() - playerArm.get_rot() - get_rot())
		
	if (Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")):
		if is_prone != true:
			anim = "run_r"
		elif is_prone == true:
			anim = "prone_crawl_r"
			
	if (Input.is_action_pressed("ui_right") == false and Input.is_action_pressed("ui_left") == false):
		if velocity.x > 0:
			velocity.x = max(velocity.x - ACCELERATION * acceleration_modifier, 0)
		else:
			velocity.x = min(velocity.x + ACCELERATION * acceleration_modifier, 0)
		if is_crouch != true and is_prone != true:
			anim = "idle_r"
		elif is_crouch == true and is_prone != true:
			anim = "crouch_idle_r"
		elif is_prone == true:
			anim = "prone_idle_r"
	velocity += force*delta
	var motion = velocity*delta + knockback_velocity
	motion = move(motion)
	var floor_velocity = Vector2()
	
	if (is_colliding()):
		var n = get_collision_normal()
		
		if (rad2deg(acos(n.dot(Vector2(0, -1)))) < FLOOR_ANGLE_TOLERANCE):
			on_air_time = 0
			floor_velocity = get_collider_velocity()
			if (stop):
				var vsign = sign(velocity.x)
				var vlen = abs(velocity.x)
		
				vlen -= STOP_FORCE*delta
				if (vlen < 0):
					vlen = 0
				velocity.x = vlen*vsign
			acceleration_modifier = 1
			if Input.is_action_pressed("ui_left"):
				velocity.x = min(velocity.x - ACCELERATION * acceleration_modifier, -WALK_SPEED)
			elif Input.is_action_pressed("ui_right"):
				velocity.x = max(velocity.x + ACCELERATION * acceleration_modifier, WALK_SPEED)	

			
			if abs((rad2deg(acos(n.dot(Vector2(0, -1))))) - get_rotd()) < .1 or (rad2deg(acos(n.dot(Vector2(0, -1))))) == 0:
				set_rotd((rad2deg(acos(n.dot(Vector2(0, -1))))))
#				print("woop")
			elif get_collider().get_name() == "slope_left" and (rad2deg(acos(n.dot(Vector2(0, -1)))) * - 1) < get_rotd():
				rotate(-.1)
			elif get_collider().get_name() != "slope_left" and (rad2deg(acos(n.dot(Vector2(0, -1))))) > get_rotd() and (rad2deg(acos(n.dot(Vector2(0, -1))))) >= 0:
				rotate(.1)
			elif (rad2deg(acos(n.dot(Vector2(0, -1))))) == 0 and get_rotd() > 0:
				rotate(-.1)

		if (on_air_time == 0 and velocity.x == 0 and get_travel().length() < SLIDE_STOP_MIN_TRAVEL and abs(velocity.x) < SLIDE_STOP_VELOCITY and get_collider_velocity() == Vector2()):
			revert_motion()
			velocity.y = 0.0
		else:	
			motion = n.slide(motion)
			velocity = n.slide(velocity)
			move(motion)
	else:
		if get_rotd() > 0 and grounded == false and velocity.y > 5:
			rotate(-.05)
#			print("mmkay")
		elif get_rotd() < 0 and grounded == false and velocity.y > 5:
			rotate(.05)
#			print("yakay")
	if (floor_velocity != Vector2()):
		move(floor_velocity*delta) 
		
	on_air_time += delta
		
	if anim != animNew:
		animNew = anim
		playerAnimNode.play(anim)
		
	if armanim != armanimnew:
		armanimnew = armanim
		playerArmAnimNode.play(armanim)
		
	if is_prone:
		get_node("prone").set_trigger(false)
		get_node("standing").set_trigger(true)
		get_node("prone").set_pos(get_node("AnimatedSprite").get_pos())
	else:
		get_node("standing").set_trigger(false)
		get_node("prone").set_trigger(true)
		get_node("standing").set_pos(get_node("AnimatedSprite").get_pos())
		
	if knockback_velocity.x != 0 or knockback_velocity.y != 0:
#		print(knockback_velocity)
		knockback_velocity.x = knockback_velocity.x - ACCELERATION
		knockback_velocity.y = knockback_velocity.y + ACCELERATION
		if knockback_velocity.x < ACCELERATION:
			knockback_velocity.x = 0
		if knockback_velocity.y >= 0:
			knockback_velocity.y = 0
#	armanim = ""
#	print (velocity.x)