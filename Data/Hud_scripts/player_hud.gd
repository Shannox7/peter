extends Control
var icons = preload("res://Inventory_icons.tscn")
var loaded = false

var listx = 0

var bullet_list = []
var player

var Global

var poison_time = 1.0
var poison_time_total = 1.0
var food_time = 0.0
var food_time_total = 30.0

var item = null
var item_dup = null
var hud_display = [[],[],[],[],[]]

var volume = 0
var volume_max = 120
var assaulting = false

func volume(increase):
	if not assaulting:
		volume += increase
		if volume >= volume_max:
			volume = volume_max
			Global.assault()
			assaulting = true

func place(item, number):
	var dup = item.duplicate()
	player.quick_use[number].append(item)
	hud_display[number].append(dup)
	add_child(dup)
	dup.set_global_pos(get_node("quick_use/Sprite" + str(number)).get_global_pos() + Vector2(12, 12))
	update_quick_select()
#	pass

func placing(selected):
	item = selected
	item_dup = item.duplicate()
	add_child(item_dup)
	place_selector()
	set_process_input(true)

func stop_placing():
	set_process_input(false)
	item_dup.queue_free()
	player.I.get_node("inventory").placing = false
	

func position():
	set_global_pos(Vector2(0,0))
	
func _ready():
	if loaded == false:
		loaded = true
#		set_process_input(true)
		get_tree().get_root().connect("size_changed", self, "position")
	pass
#	hud_list
func shoot(player):
	pass
#	bullet_list.back().unlock()
#	bullet_list.pop_back()
	
func clear_ammo():
	for bullet in range(bullet_list.size()):
		bullet_list.back().unlock()
		bullet_list.pop_back()
		
func ammo(player):
	var numbery = 0
	var numberx = 0
	for bullet in range(player.bullet_list.size()):
		if numberx == 50:
			numbery += 10
			numberx = 0
		var new_bullet = icons.instance().get_node("Ammo/bullet").duplicate()
		new_bullet.set_pos(Vector2(get_node("ammo_position").get_pos().x + new_bullet.size * numberx, get_node("ammo_position").get_pos().y + numbery))
		bullet_list.append(new_bullet)
		call_deferred("deferred", new_bullet)
		numberx +=1

func deferred(defer):
	add_child(defer)

func update_quick_select():
	var number = 0
	for list in player.quick_use:
		if list != []:
			get_node("quick_use/Sprite" + str(number)+"/Label").set_text(str(list[0].amount))
			if list[0].amount <= 0:
				if hud_display[number] != []:
					hud_display[number][0].queue_free()
				hud_display[number].clear()
				list.clear()
				get_node("quick_use/Sprite" + str(number)+"/Label").set_text("")
#				list[0].free()
				
		number += 1

func update_hud():
	var scale = 100
	if player.level.chase_list != [] or Global.chasing_list != []:
		get_node("hidden").set_text("Chase!: " + str(player.level.chase_list.size() + Global.chasing_list.size()))
	else:
		get_node("hidden").set_text("Hidden")
	if player.primaryGun != []:
		if player.current_ammo > 0:
			get_node("ammo_meter/ammo").show() 
			get_node("ammo_meter/ammo").set_scale(Vector2((player.primaryGun[0].current_clip/player.primaryGun[0].clip_capacity) * scale, 1)) 
		else:
			get_node("ammo_meter/ammo").hide()
		
		get_node("Label 2").set_text(str(player.current_ammo) + "/" + str(player.primaryGun[0].current_clip))
		if player.reloading:
			get_node("Label 2").set_text(str(player.primaryGun[0].current_clip) + "/" + str(player.current_ammo))
	else:
		get_node("ammo_meter/ammo").hide()
		get_node("Label 2").set_text("Unarmed")
	
	get_node("Label 3").set_text("Health: " + str(round(player.health)))
	get_node("Label 5").set_text("Food: " + str(player.food))
	get_node("Label 4").set_text("Medicine: " + str(player.medicine))
	
	get_node("trade").set_text("$" + str(player.trade))
 
		
	if volume > 0:
		get_node("volume/volume").show() 
		get_node("volume/volume").set_scale(Vector2((volume/volume_max) * scale, 1)) 
	else:
		get_node("volume/volume").hide() 
	if player.poison > 0:
		get_node("poison_meter/poison").show() 
		get_node("poison_meter/poison").set_scale(Vector2((player.poison/player.poison_total) * scale, 1)) 
	else:
		get_node("poison_meter/poison").hide() 
	if food_time > 0:
		get_node("food_meter/food").show() 
		get_node("food_meter/food").set_scale(Vector2((food_time/food_time_total) * scale, 1)) 
	else:
		get_node("food_meter/food").hide() 
#get_node("poison_meter/poison").set_modulate(Color(255, 0, 0))
func _input(event):
	if event.is_action_pressed(str(player.joy) + "select_left"):
		if listx > 0:
			listx -= 1
		place_selector()
	elif event.is_action_pressed(str(player.joy) + "select_right"):
		if listx < player.quick_use.size() -1:
			listx += 1
		place_selector()
	elif event.is_action_pressed(str(player.joy) + "interact"):
		var number = 0
		for list in player.quick_use:
			if list != []:
				if item == list[0]:
					list.pop_front()
					if hud_display[number] != []:
						hud_display[number][0].queue_free()
					hud_display[number] = []
					get_node("quick_use/Sprite" + str(number)+"/Label").set_text("")
			number += 1
		if player.quick_use[listx] != []:
			player.quick_use[listx] = []
			if hud_display[listx] != []:
				hud_display[listx][0].queue_free()
			hud_display[listx] = []
		player.quick_use[listx].append(item)
		hud_display[listx].append(item_dup)
		item_dup.set_global_pos(get_node("quick_use/Sprite" + str(listx)).get_global_pos() + Vector2(12, 12))
		player.I.get_node("inventory").placing = false
		set_process_input(false)
		update_quick_select()
		
#	elif event.is_action_pressed("crouch"):
#		item_dup.queue_free()
#		player.I.get_node("inventory").placing = false
#		set_process_input(false)
#	pass
	
func place_selector():
	get_node("selector").set_global_pos(get_node("quick_use/Sprite" + str(listx)).get_global_pos())
	if player.I.get_node("inventory").placing == true:
		item_dup.set_global_pos(get_node("quick_use/Sprite" + str(listx)).get_global_pos())

func _fixed_process(delta):
	if volume >= 0 and not assaulting:
		volume -= delta
		if volume <= 0:
			volume = 0 
	elif assaulting:
		volume -= delta * 2
		if volume <= 0:
			volume = 0 
			assaulting = false
	if player.bonus_health > 0:
		player.bonus_health -= delta/10
		player.health()
	elif player.bonus_health < 0:
		player.bonus_health = 0
	food_time += delta
	if food_time >= food_time_total:
		if player.food <= 0:
			player.health -= 10
		else:	
			player.food -= 1
		food_time = 0
	if player.poison >= player.poison_total:
		player.poison = player.poison_total
		if player.medicine <= 0:
			poison_time -= delta
			if poison_time <= 0:
				player.health -= 1
				poison_time = poison_time_total
		else:	
			player.medicine -= 1
			player.poison = 0
			poison_time = poison_time_total
	update_hud()
