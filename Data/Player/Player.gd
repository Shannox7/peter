extends KinematicBody2D
export var AIMSPEED = .05
var place = false
#slopes V
var pack = []
var utility = [[],[],[],[],[],[],[],[]]
var knockback_velocity = Vector2()
var total_health = 50
var current_health = 50
var armour = 0
var total_ammo = 0
var current_ammo = 0
var health
var money = 400
var healthpos
var flip_mod = 1
const IDLE_SPEED = 10

var aim = false
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
var is_prone = false

var bullet = preload("res://PlayerAttacks.tscn")
var deployables = preload("res://Deployables.tscn")
var allies = preload("res://Allies.tscn")
var i = preload("res://Inventory_hud.tscn")
var I

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
var reload
var reloading = false
var fire_ready
var fire = false
var ally_list = []
var inventory = false
var hold = false
func _ready():
	set_fixed_process(true)
	set_process_input(true)
	playerAnimNode = get_node("AnimatedSprite")
	playerArmAnimNode = get_node("Arm")
	playerHead= get_node("Head")
	playerArm= get_node("Arm")
	reload = get_node("reload")
	reload.connect("timeout", self, "reloaded")
	fire_ready = get_node("fire_ready")
	fire_ready.connect("timeout", self, "fireready")
#	healthBar = get_node("healthbar")
	get_parent().get_parent().health_bars(total_health)
	health = total_health
#	add_collision_exception_with(get_node("Head"))
	I = i.instance()
	var machinegun_turret = deployables.instance().get_node("machinegun_turret").duplicate()
	pack.append(machinegun_turret)
	var mine = deployables.instance().get_node("mine")
	pack.append(machinegun_turret.duplicate())
	pack.append(mine.duplicate())
	mine.deactivate()
	machinegun_turret.deactivate()
func prone(proned):
	if proned:
		set_pos(Vector2(0, 12))
	else:
		set_pos(Vector2(0, 0))
func flip(flipped):
	if flipped:
		flip_mod = -1
	else:
		flip_mod = 1
	playerAnimNode.set_flip_h(flipped)
	playerHead.set_flip_h(flipped)
	playerArm.set_flip_h(flipped)
	if headArmour != []:
		headArmour[0].get_node("Sprite").set_flip_h(flipped)
	if bodyArmour != []:
		bodyArmour[0].get_node("Sprite").set_flip_h(flipped)
	if playerGun != []:
		playerGun[0].flip(flipped)
	if secondaryGun != []:
		secondaryGun[0].flip(flipped)
	
	get_node("headcollision").set_pos(playerHead.get_pos())
	if get_parent().is_prone != true:
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

	elif get_parent().is_prone == true:
		get_node("AnimatedSprite").set_pos(Vector2(-4 * flip_mod, -2))
		playerHead.set_pos(Vector2(12 * flip_mod, -6))
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

func display(button, description):
	if button == null:
		get_node("Label").set_text(" ")
	else:
		get_node("Label").set_text(str(button) + " " + description)
	
func fireready():
	if playerGun != []:
		fire = true
		fire_ready.set_wait_time(playerGun[0].fire_rate)
		fire_ready.start()
#fun unequip(item):
func unequip(itemvar):
	itemvar[0].get_parent().remove_child(itemvar[0])
	itemvar[0].named = str(itemvar[0].name)
	itemvar[0].is_equipped = false
	itemvar.pop_front()
	
func equip(item, pickedup, slot):
	item.is_equipped = true
	item.named = ("-E- " + str(item.name))
	if item.is_in_group("weapons") and slot == "playerGun":
		if playerGun != [] and secondaryGun != []:
			get_parent().get_parent().clear_ammo()
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
		get_parent().get_parent().clear_ammo()
		get_parent().get_parent().ammo(self)
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
			item.set_rot(0)
			headArmour[0].equip(self)
			get_parent().get_parent().health_bars(total_health)
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
			item.set_rot(0)
			bodyArmour[0].equip(self)
			get_parent().get_parent().health_bars(total_health)
	if flip_mod == -1:
		flip(true)
	else:
		flip(false)
func fire():
	fire = false
	fire_ready.stop()
	get_parent().get_parent().shoot(self)
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
#	var bullets = bullet_list.back().size() - 1
	for bullets in playerGun[0].bullet_list.back():
#		print(playerGun[0].bullet_list.back())
#		print("bullets: ")
#		print(bullets)
#		print (lists)
		if flip_mod == -1:
			bullets.get_node("Sprite").set_flip_h(true)  
			bullets.flip_mod = -1
		bullets.set_rotd(rad2deg(Aimrot) + rand_range(playerGun[0].accuracy, -playerGun[0].accuracy))
		bullets.set_pos(spawn_point)
		get_parent().get_parent().add_child(bullets)
#		bullets -= 1
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
	get_parent().get_parent().clear_ammo()
	get_parent().get_parent().ammo(self)
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
	get_parent().get_parent().update_hud()
	
func selected(number):
#	print(utility)
	if utility[number] != []:
		selectednumber = number
		if selected_display != null:
			selected_display.queue_free()
			selected_display = null
		selected_display = utility[number][0].duplicate()
		selected_display.deactivate()
		get_parent().get_parent().update_selected(selected_display)
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

func _input(event):
	if event.is_action_pressed("inventory"):
		if inventory == false:
			I.get_node("inventory").set_global_pos(Vector2(get_viewport_rect().size.x/ 2, get_viewport_rect().size.y/ 4))
#			get_parent().get_parent()
			get_viewport().add_child(I)
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
		ally.set_pos(Vector2(get_global_pos().x - 100 * flip_mod, get_global_pos().y))
		ally.owner = self
		get_parent().get_parent().get_parent().add_child(ally)
		ally_list.append(ally)
		
	if event.is_action_pressed("switch") and (playerGun != [] or secondaryGun != []):
		swap()
	if event.is_action_pressed("fire") and playerGun != []: 
		if fire == true and playerGun[0].current_ammo > 0 and playerGun[0].current_clip > 0 and playerGun[0].fullauto == false:
			fire()
	elif event.is_action_pressed("fire") and playerGun != []: 
		if fire == true and playerGun[0].current_clip == 0 and playerGun.current_ammo > 0:
			print ("click")
			print ("click")
			reload()

func swap():
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
	get_parent().get_parent().clear_ammo()
	update_hud()
	get_parent().get_parent().ammo(self)
	if flip_mod == -1:
		flip(true)
	else:
		flip(false)

func hit(collider):
	if collider.get_global_pos().y < collider.get_global_pos().y:
		print ("critical")
		collider.damage = collider.damage * 2

	knockback_velocity.x = collider.velocity.x * collider.stopping_power
	knockback_velocity.y = collider.velocity.y * collider.stopping_power
#	print("bullet_velocity: " + str(collider.velocity)) 
#	if dead == false:
	get_parent().get_parent().hit(self, collider.damage)

func deferred(defer):
	add_child(defer)
	
func _fixed_process(delta):
	if Input.is_action_pressed("fire") and playerGun != []: 
		if fire == true and playerGun[0].fullauto == true and playerGun[0].current_clip > 0:
			fire()

	if Input.is_action_pressed("ui_lookup") and get_node("Head").get_rotd() <= 90 and flip_mod == 1:
		playerHead.rotate(AIMSPEED)
	elif Input.is_action_pressed("ui_lookup") and playerHead.get_rotd() >= -90 and flip_mod == -1:
		playerHead.rotate(-AIMSPEED)
		
	if Input.is_action_pressed("ui_lookdown") and playerHead.get_rotd() > -90 and flip_mod == 1:
		playerHead.rotate(-AIMSPEED)
	elif Input.is_action_pressed("ui_lookdown") and playerHead.get_rotd() < 90 and flip_mod == -1:
		playerHead.rotate(AIMSPEED)
				
	if Input.is_action_pressed("ui_lookup") and playerArm.get_rotd() <= 90 and flip_mod == 1:
		playerArm.rotate(AIMSPEED)
	elif Input.is_action_pressed("ui_lookup") and playerArm.get_rotd() >= -90 and flip_mod == -1:
		playerArm.rotate(-AIMSPEED)

	if Input.is_action_pressed("ui_lookdown") and playerArm.get_rotd() >= -90 and flip_mod == 1:
		playerArm.rotate(-AIMSPEED)

	elif Input.is_action_pressed("ui_lookdown") and playerArm.get_rotd() <= 90 and flip_mod == -1:
		playerArm.rotate(AIMSPEED)
	
	if Input.is_action_pressed("ui_ctrl"):
		armanim = "aim"
		aim = true
		AIMSPEED = .01
	else:
		AIMSPEED = .05
		aim = false
#move collision		

		
	if place == true:
		selected.set_pos(Vector2(playerArm.get_pos().x + 100, playerArm.get_pos().y)  * flip_mod)
		selected.set_rot(get_rot() - playerArm.get_rot() - get_rot())
		
	if anim != animNew:
		animNew = anim
		playerAnimNode.play(anim)
		
	if armanim != armanimnew:
		armanimnew = armanim
		playerArmAnimNode.play(armanim)
		
#	if is_prone:
#		get_node("prone").set_trigger(false)
#		get_node("standing").set_trigger(true)
#		get_node("prone").set_pos(get_node("AnimatedSprite").get_pos())
#	else:
#		get_node("standing").set_trigger(false)
#		get_node("prone").set_trigger(true)
#		get_node("standing").set_pos(get_node("AnimatedSprite").get_pos())

#	armanim = ""
#	print (velocity.x)