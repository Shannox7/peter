extends Node2D

var world_list
var point

var selfy
var player
var attacking = false
var attacker
var new
var original
var selected
var Global

var attacker_force = 0

var follow

var highlight_total = 1.75
var highlighting = false
var highlight_reverse = false
var highlight = 1
var attack = false
var start = true
func _ready():
	Global = get_node("/root/Global")
	if start:
		for maps in get_node("Map").get_children():
			maps.players.append(Global.AI.duplicate())
			maps.AI = true
		start = false
		get_node("Map/US and Canada").players.pop_front()
		get_node("Map/US and Canada").AI = false
		get_node("Map/US and Canada").controller = selfy
		get_node("Map/US and Canada").players.append(selfy.get_ref())
		
	get_node("follow/Label").set_text("Select?")
	follow = get_node("follow")
	original = get_node("Map").get_children().front()
	selected = get_node("Map").get_children()[get_node("Map").get_children().find(original)]
	get_node("follow").set_global_pos(original.get_global_pos())
	set_process_input(true)
	highlight(true)
	pass

func _input(event):
	if not attack:
		if event.is_action_pressed("interact") and attacking == false:
			if selected.controller == selfy:
				if selfy.get_ref().reinforcements >0:
					selected.reinforcements()
					selfy.get_ref().reinforcements -= 1
			else:
				print("i dont own this")
		if event.is_action_pressed("ui_right"):
			var start = false
			for land in get_node("Map").get_children():
				if land.get_global_pos().x < original.get_global_pos().x or not land.get_global_pos().y in range(original.get_global_pos().y - 100, original.get_global_pos().y + 100) or land == original:
					pass
				elif start == false:
					start = true
					new = land 
				elif original.get_global_pos().distance_to(land.get_global_pos()) < original.get_global_pos().distance_to(new.get_global_pos()):
					new = land 
			selector()
		elif event.is_action_pressed("ui_left"):
			var start = false
			for land in get_node("Map").get_children():
				if land.get_global_pos().x > original.get_global_pos().x or not land.get_global_pos().y in range(original.get_global_pos().y - 100, original.get_global_pos().y + 100) or land == original:
					pass
				elif start == false:
					start = true
					new = land 
				elif original.get_global_pos().distance_to(land.get_global_pos()) < original.get_global_pos().distance_to(new.get_global_pos()):
					new = land 
			selector()
		elif event.is_action_pressed("ui_up"):
			var start = false
			for land in get_node("Map").get_children():
				if land.get_global_pos().y > original.get_global_pos().y or not land.get_global_pos().x in range(original.get_global_pos().x - 100, original.get_global_pos().x + 100) or land == original:
					pass
				elif start == false:
					start = true
					new = land 
				elif original.get_global_pos().distance_to(land.get_global_pos()) < original.get_global_pos().distance_to(new.get_global_pos()):
					new = land 
			selector()
		elif event.is_action_pressed("ui_down"):
			var start = false
			for land in get_node("Map").get_children():
				if land.get_global_pos().y < original.get_global_pos().y or not land.get_global_pos().x in range(original.get_global_pos().x - 100, original.get_global_pos().x + 100) or land == original:
					pass
				elif start == false:
					start = true
					new = land 
				elif original.get_global_pos().distance_to(land.get_global_pos()) < original.get_global_pos().distance_to(new.get_global_pos()):
					new = land 
			selector()

		if event.is_action_pressed("place") and attacking == false:
			if selected.controller == selfy:
				attacking = true
				attacker = selected
				attacker.battle()
				selected.battle()
				get_node("follow/Label").set_text("Attack who? ")

		elif event.is_action_pressed("place") and attacking == true:
			if selected != attacker:
				attack = true
				get_node("follow/Label").set_text("Attack with: " + str(attacker_force))

	if attack:
		if event.is_action_pressed("ui_up"):
			if attacker.infantry > 0:
				attacker_force += 1
				attacker.remove(1)
				get_node("follow/Label").set_text("Attack with: " + str(attacker_force))

		elif event.is_action_pressed("ui_down"):
			if attacker_force > 0:
				attacker_force -= 1
				attacker.add(1)
				get_node("follow/Label").set_text("Attack with: " + str(attacker_force))

		if event.is_action_pressed("interact") and attacker_force > 0:
			var attack_force = attacker_force
			attacker_force = 0
			attacker.battle()
#			selected.battle()
			attack = false
			attacking = false
			get_node("follow/Label").set_text("select?")
			get_node("/root/Global").generate_attack(self, attacker, selected, attack_force)

	if event.is_action_pressed("command") and attack == true:
		attack = false
		attacker.add(attacker_force)
		attacker_force = 0
		get_node("follow/Label").set_text("Attack?")
	elif event.is_action_pressed("command") and attacking == true:
		attacking = false
		get_node("follow/Label").set_text("Select?")
	elif event.is_action_pressed("command"):
			get_node("/root/Global").unload_map(get_node("/root/Global").Base)

func selector():
	if new != null:
		highlight(false)
		highlight = 1
		original = new
		get_node("follow").set_global_pos(new.get_global_pos())
		selected =get_node("Map").get_children()[get_node("Map").get_children().find(new)]
		highlight(true)
	if attacking:
		if attacker != selected:
			get_node("follow/Label").set_text("Attack: " + str(selected.get_name()))

func highlight(val):
	highlighting = val
	if not highlighting:
		set_fixed_process(false)
		selected.get_node("Sprite").set_modulate(Color(1,1,1))
	else:
		set_fixed_process(true)

func _fixed_process(delta):
	if highlighting:
		if highlight > highlight_total or highlight_reverse:
			highlight_reverse = true
			highlight -= delta
			if highlight < 1:
				highlight_reverse = false
		else:
			highlight += delta
		selected.get_node("Sprite").set_modulate(Color(highlight,highlight,highlight))
#	print(str(highlight))
#func start(p):
#	pos = null
#	for point in world_list:
#		if point.get_ref().side == faction.side:
#			if pos == null:
#				pos = point
#			elif player.get_global_pos().distance_to(point.get_ref().get_global_pos()) < player.get_global_pos().distance_to(pos.get_ref().get_global_pos()):
#				pos = point
#		get_node("follow").set_global_pos(Vector2(pos.get_ref().get_global_pos().x, pos.get_ref().get_global_pos().y - 20 ))
#
#	player = p.get_ref()
#	player.get_node("Camera2D").clear_current()
#	get_node("follow/Camera2D").make_current()
#	get_node("build_upgrade/build_ui").show()
#	set_process_input(true)
#	set_fixed_process(true)
#	player.set_process_input(false)
#	player.set_fixed_process(false)
#	
#func close():
#	get_node("follow/Camera2D").clear_current()
#	set_process_input(false)
#	set_fixed_process(false)
#	player.get_node("Camera2D").make_current()
#	player.set_process_input(true)
#	player.set_fixed_process(true)
#	get_node("build_upgrade/build_ui").hide()
#	player.windows = false