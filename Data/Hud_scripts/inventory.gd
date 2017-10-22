extends Control
var player
var display
var inventory_x = 0
var inventory_y = 0
var crafting_y = 0
var itemlist_group = "weapons"
var current_list = []
var utility = [[],[],[],[],[],[],[],[],[]]
var utility_display = [[],[],[],[],[],[],[],[],[]]
var boxlist = [[],[],[],[],[],[],[],[],[],[]]
var duplicatelist = [[],[]]
var modding = [[],[],[],[],[]]
var mod_with = [[],[],[],[],[]]
var primaryGun
var secondaryGun
var headArmour
var bodyArmour
var dup_display
var base_item
var deploynumber
var placing = false
var selecting = false
func _ready():
	set_process_input(true)
	boxlist = [get_node("boxes/box1"), get_node("boxes/box2"), get_node("boxes/box3"), get_node("boxes/box4"), get_node("boxes/box5"), get_node("boxes/box6"), get_node("boxes/box7"), get_node("boxes/box8"), get_node("boxes/box9")]
func show_inventory(Player):
	if inventory_x == 0:
		itemlist_group = "weapons"
	elif inventory_x == 1:
		itemlist_group = "armour"
	elif inventory_x == 2:
		itemlist_group = "deployables"
	elif inventory_x == 3:
		itemlist_group = "guns and parts"
	player = Player
	get_node("list").clear()
	current_list.clear()
	equipped_display(itemlist_group)
	if player.pack != []:
		for items in player.pack:
			if items.is_in_group(itemlist_group):
#				var displayitems = items.duplicate()
				if itemlist_group == "deployables":
					items.deactivate()
				current_list.append(items)
				get_node("list").append_bbcode(str(items.named) +'\n')
		if inventory_y == null:
			pass
		elif inventory_y > current_list.size() - 1 and current_list != []:
			inventory_y = current_list.size() - 1
			pack_display(inventory_y)
		elif current_list != []:
			pack_display(inventory_y)
		else:
			selecting = false
			inventory_y = null
							
func close_crafting(modded, modwith):
	if modding[0] != [] and modded == true:
		modding[0][0].equip_display(modding[0][0].barrel[0], "barrel")
		modding[0][0].equip_display(modding[0][0].sight[0], "sight")
		modding[0][0].equip_display(modding[0][0].special[0], "special")
		modding[0][0].equip_display(modding[0][0].clip[0], "clip")
		if modding[0][0].get_parent() != null:
			modding[0][0].get_parent().remove_child(modding[0][0])
		get_node("modding/special/special_label").clear()
		get_node("modding/sight/sight_label").clear()
		get_node("modding/clip/clip_label").clear()
		get_node("modding/barrel/barrel_label").clear()
		get_node("modding/body/body_label").clear()
		modding = [[],[],[],[],[]]
	if mod_with[0] != [] and modwith == true:
		mod_with[0][0].equip_display(mod_with[0][0].barrel[0], "barrel")
		mod_with[0][0].equip_display(mod_with[0][0].sight[0], "sight")
		mod_with[0][0].equip_display(mod_with[0][0].special[0], "special")
		mod_with[0][0].equip_display(mod_with[0][0].clip[0], "clip")
		if mod_with[0][0].get_parent() != null:
			mod_with[0][0].get_parent().remove_child(mod_with[0][0])
		get_node("mod_with/special/special_label").clear()
		get_node("mod_with/sight/sight_label").clear()
		get_node("mod_with/clip/clip_label").clear()
		get_node("mod_with/barrel/barrel_label").clear()
		get_node("mod_with/body/body_label").clear()
	mod_with = [[],[],[],[],[]]
func remove_inventory(player):
	inventory_y = 0
	inventory_x = 0
	current_list.clear()
	set_process_input(false)
	selecting = false
	placing = false
	if mod_with != [[],[],[],[],[]]:
		close_crafting(false, true)
	if modding != [[],[],[],[],[]]:
		close_crafting(true, false)
func remove_item(item):
	var packsize = 0
	for items in player.pack:
#		print (items)
		if items.get_instance_ID() == player.utility[item][0].get_instance_ID():
			player.pack.remove(packsize)
#			utility_display[item][0].get_parent().remove_child(utility_display[item][0])
		packsize += 1
	player.utility[item].clear()
	utility_display[item][0].free()
	utility_display[item].clear()

func equipped_display(group):
	if display != null:
		display.queue_free()
		display = null
	get_node("Label").clear()
	get_node("Label1").clear()
	get_node("Label2").clear()
	if primaryGun != null:
		primaryGun.get_parent().remove_child(primaryGun)
		primaryGun.free()
		primaryGun = null
	if secondaryGun != null:
		secondaryGun.get_parent().remove_child(secondaryGun)
		secondaryGun.free()
		secondaryGun = null
	if headArmour != null:
		headArmour.get_parent().remove_child(headArmour)
		headArmour.free()
		headArmour = null
	if bodyArmour != null:
		bodyArmour.get_parent().remove_child(bodyArmour)
		bodyArmour.free()
		bodyArmour = null
	if group == "deployables":
		get_node("boxes").set_opacity(1)
	else:
		get_node("boxes").set_opacity(0)
	if group == "weapons":
		if player.primaryGun != []:
			primaryGun = player.primaryGun[0].duplicate()
			primaryGun.set_pos(get_node("display_pos1").get_pos())
			primaryGun.set_rot(get_node("display_pos1").get_rot())
	#		primaryGun.flip(false)
			add_child(primaryGun)
			get_node("Label1").append_bbcode(str(player.primaryGun[0].name) + "\n")
			for stats in player.primaryGun[0].stats:
				get_node("Label1").append_bbcode(str(stats) + "\n")
		if player.secondaryGun != []:
			secondaryGun = player.secondaryGun[0].duplicate()
			secondaryGun.set_pos(get_node("display_pos2").get_pos())
			secondaryGun.set_rot(get_node("display_pos2").get_rot())
#			secondaryGun.flip(false)
			add_child(secondaryGun)
			get_node("Label2").append_bbcode(str(player.secondaryGun[0].name) + "\n")
			for stats in player.secondaryGun[0].stats:
				get_node("Label2").append_bbcode(str(stats) + "\n")
	elif group == "armour":
		if player.headArmour != []:
			headArmour = player.headArmour[0].duplicate()
			headArmour.set_pos(get_node("display_pos1").get_pos())
			headArmour.set_rot(get_node("display_pos1").get_rot())
	#		primaryGun.flip(false)
			add_child(headArmour)
			get_node("Label1").append_bbcode(str(player.headArmour[0].name) + "\n")
			for stats in player.headArmour[0].stats:
				get_node("Label1").append_bbcode(str(stats) + "\n")
		if player.bodyArmour != []:
			bodyArmour = player.bodyArmour[0].duplicate()
			bodyArmour.set_pos(get_node("display_pos2").get_pos())
			bodyArmour.set_rot(get_node("display_pos2").get_rot())
#			secondaryGun.flip(false)
			add_child(bodyArmour)
			get_node("Label2").append_bbcode(str(player.bodyArmour[0].name) + "\n")
			for stats in player.bodyArmour[0].stats:
				get_node("Label2").append_bbcode(str(stats) + "\n")
func display(part, position, display, list, parent):
	if display:
		if part.get_parent() != null:
			part.get_parent().remove_child(part)
		part.set_pos(get_node(str(parent) + "/" + str(position)).get_pos())
		get_node(str(parent)).add_child(part)
#		print (part.stats)
		for stats in part.stats:
#			print(stats)
			get_node(str(parent) + "/" + str(position) + "/" + str(position) + "_label").append_bbcode(str(stats) + "\n")
#		get_node(str(parent) + "/" + str(position) + "/name").set_text(part.name)
#	if !display:
#		part.get_parent().remove_child(part)
#		part.equip_display(part, position)
		
func pack_display(item):
#	if utility_display[8] != []:
#		utility_display[8][0].queue_free()
#		utility_display[8].clear()
#		placing = false
	if item != null:
		if display != null and current_list != []:
			display.free()
		display = current_list[item].duplicate()
		display.set_pos(get_node("display_pos").get_pos())
		display.set_rot(get_node("display_pos").get_rot())
		add_child(display)
		get_node("Label").append_bbcode(str(current_list[item].name) + "\n")
		for stats in current_list[item].stats:
			get_node("Label").append_bbcode(str(stats) + "\n")
		selecting = true
	else:
		selecting = false
func selector(selecting):
	var selectors = [[get_node("select")],[get_node("select1")],[get_node("select2")],[get_node("select3")],[get_node("select4")]]
	for lists in selectors:
		lists[0].set_opacity(0)
	if selecting:
		selectors[crafting_y][0].set_opacity(1)
func swap():
	var location
	if crafting_y == 0:
#		location = "body"
		mod_with[0].push_front(modding[0][0])
		modding[0].push_front(mod_with[0][1])
		modding[0].pop_back()
		mod_with[0].pop_back()

		modding[0][0].equip(mod_with[0][0].barrel[0], "barrel")
		modding[0][0].equip(mod_with[0][0].sight[0], "sight")
		modding[0][0].equip(mod_with[0][0].clip[0], "clip")
		modding[0][0].equip(mod_with[0][0].special[0], "special")
		
		mod_with[0][0].equip(modding[0][0].barrel[1], "barrel")
		mod_with[0][0].equip(modding[0][0].sight[1], "sight")
		mod_with[0][0].equip(modding[0][0].clip[1], "clip")
		mod_with[0][0].equip(modding[0][0].special[1], "special")
		
		modding[0][0].unequip(modding[0][0].barrel[0], "barrel")
		modding[0][0].unequip(modding[0][0].sight[0], "sight")
		modding[0][0].unequip(modding[0][0].clip[0], "clip")
		modding[0][0].unequip(modding[0][0].special[0], "special")
		
		mod_with[0][0].unequip(mod_with[0][0].barrel[0], "barrel")
		mod_with[0][0].unequip(mod_with[0][0].sight[0], "sight")
		mod_with[0][0].unequip(mod_with[0][0].clip[0], "clip")
		mod_with[0][0].unequip(mod_with[0][0].special[0], "special")
	else:
		if crafting_y == 1:
			location = "clip"
		elif crafting_y == 2:
			location = "special"
		elif crafting_y == 3:
			location = "sight"
		elif crafting_y == 4:
			location = "barrel"
		modding[0][0].equip(mod_with[crafting_y][0], location)
		mod_with[0][0].equip(modding[crafting_y][0], location)
		modding[0][0].unequip(modding[crafting_y][0], location)
		mod_with[0][0].unequip(mod_with[crafting_y][0], location)
		mod_with[crafting_y].push_front(modding[crafting_y][0])
		modding[crafting_y].push_front(mod_with[crafting_y][0])
		mod_with[crafting_y].pop_back()
		modding[crafting_y].pop_back()
	close_crafting(true, true)
	selector(false)
	inventory_x = 2
	show_inventory(player)
	
func _input(event):
	if placing == true and (event.is_action_released("select_down") or event.is_action_released("select_left") or event.is_action_released("select_up") or event.is_action_released("select_right")):
		var number
#		if event.is_action_pressed("ui_down") and event.is_action_pressed("ui_right"):
		if event.is_action_released("select_down") and event.is_action_released("select_right"):
			number = 5
		elif event.is_action_released("select_down") and event.is_action_released("select_left"):
			number = 7
		elif event.is_action_released("select_up") and event.is_action_released("select_left"):
			number = 1
		elif event.is_action_released("select_up") and event.is_action_released("select_right"):
			number = 3
		elif event.is_action_released("select_right"):
			number = 4
		elif event.is_action_released("select_left"):
			number = 0 
		elif event.is_action_released("select_up"):
			number = 2
		elif event.is_action_released("select_down"):
			number = 6
		if number != null:
			if player.utility[number] != []:
				player.utility[number].clear()
				utility_display[number].clear()
			utility_display[number].append(dup_display)
			utility_display[8].clear()
			dup_display.set_pos(boxlist[number].get_pos()) 
			player.utility[number].append(current_list[inventory_y])
#			print(player.utility)
			player.update_hud()
			placing = false
	elif placing == false:
		if event.is_action_pressed("select_right"):
			if inventory_x == 3 and modding[0] != [] and mod_with[0] != []:
				inventory_y = 0
				selector(true)
				inventory_x +=1
			elif inventory_x < 3:
				inventory_x += 1
			show_inventory(player)
		elif event.is_action_pressed("select_left"):
			if inventory_x == 4:
				selector(false)
			elif inventory_x == 3:
				close_crafting(true, true)
			if inventory_x > 0:
				inventory_x -= 1
			show_inventory(player)
		elif event.is_action_released("select_down"):
			if inventory_y == null and current_list == []:
				pass
			elif inventory_x == 4 and crafting_y < mod_with.size() - 1:
				crafting_y += 1
				selector(true)
			elif inventory_y == null:
				inventory_y = 0
			elif inventory_y >= current_list.size() - 1:
				inventory_y = 0
			else:
				inventory_y += 1
			show_inventory(player)
		elif event.is_action_released("select_up"):
			if inventory_y == null and current_list == []:
				pass
			elif inventory_x == 4 and crafting_y > 0:
				crafting_y -= 1
				selector(true)
			elif inventory_y == null:
				inventory_y = current_list.size() - 1
			elif inventory_y <= 0:
				inventory_y = current_list.size() - 1
			else:
				inventory_y -= 1
			show_inventory(player)
		elif event.is_action_pressed("reload") and selecting == true:
			if itemlist_group == "guns and parts":
				var list = []
				var dup
				if modding != [[],[],[],[],[]]: 
					if current_list[inventory_y].get_instance_ID() != modding[0][0].get_instance_ID():
						if mod_with != [[],[],[],[],[]]:
							close_crafting(false, true)
						if current_list[inventory_y].is_equipped:
							player.unequip(player.secondaryGun)
						mod_with[0].append(current_list[inventory_y])
						mod_with[1].append(mod_with[0][0].clip[0])
						mod_with[2].append(mod_with[0][0].special[0])
						mod_with[3].append(mod_with[0][0].sight[0])
						mod_with[4].append(mod_with[0][0].barrel[0])
						display(mod_with[0][0], "body", true, mod_with, "mod_with")
						display(mod_with[0][0].barrel[0], "barrel", true, mod_with, "mod_with")
						display(mod_with[0][0].sight[0], "sight", true, mod_with, "mod_with")
						display(mod_with[0][0].special[0], "special", true, mod_with, "mod_with")
						display(mod_with[0][0].clip[0], "clip", true, mod_with, "mod_with")
					else:
						print("are ya dumb?")
			elif itemlist_group == "weapons":
#				var packsize = 0
	#			print (packsize)
						
				if player.secondaryGun != []:
					if current_list[inventory_y] == player.secondaryGun[0]:
						pass
					elif player.primaryGun != []:
						if current_list[inventory_y] == player.primaryGun[0]:
							player.swap()
						else:
							player.equip(current_list[inventory_y], false, "secondaryGun")
					else:
						player.equip(current_list[inventory_y], false, "secondaryGun")
						
				elif player.primaryGun != []:
					if current_list[inventory_y] == player.primaryGun[0]:
						player.swap()
					else:
						player.equip(current_list[inventory_y], false, "secondaryGun")
				else:
					player.equip(current_list[inventory_y], false, "secondaryGun")
			
#				for item in player.pack:
#					if item.get_instance_ID() == current_list[inventory_y].get_instance_ID():
#						player.pack.remove(packsize)
#					packsize += 1
				show_inventory(player)
#				selecting = false 
		elif event.is_action_pressed("interact") and selecting:
			if inventory_x == 4:
				swap()
			elif itemlist_group == "guns and parts":
				var list = []
				var dup
				if modding != [[],[],[],[],[]]:
					close_crafting(true, false)
				if current_list[inventory_y].is_equipped:
					player.unequip(player.primaryGun)
				modding[0].append(current_list[inventory_y])
				modding[1].append(modding[0][0].clip[0])
				modding[2].append(modding[0][0].special[0])
				modding[3].append(modding[0][0].sight[0])
				modding[4].append(modding[0][0].barrel[0])
				display(modding[0][0], "body", true, modding, "modding")
				display(modding[0][0].barrel[0], "barrel", true, modding, "modding")
				display(modding[0][0].sight[0], "sight", true, modding, "modding")
				display(modding[0][0].special[0], "special", true, modding, "modding")
				display(modding[0][0].clip[0], "clip", true, modding, "modding")
				
			elif itemlist_group == "deployables":
				if duplicatelist[0] != []:
					var grow = 0
					for item in duplicatelist[0]:
						if item.get_instance_ID() == current_list[inventory_y].get_instance_ID():
							duplicatelist[0].remove(grow)
							duplicatelist[1][grow].queue_free()
							duplicatelist[1].remove(grow)
						grow += 1
					var growing = 0
					for lists in player.utility:
						if lists != []:
							for items in lists:
								if items.get_instance_ID() == current_list[inventory_y].get_instance_ID():
									player.utility[growing].clear()
						growing += 1
				base_item = current_list[inventory_y]
				dup_display = current_list[inventory_y].duplicate()
				duplicatelist[0].push_front(base_item)
				duplicatelist[1].push_front(dup_display)
				utility_display[8].append(dup_display)
				dup_display.set_scale(Vector2(.5, .5))
				dup_display.set_pos(get_node("boxes/box9").get_pos())
				get_node("boxes").add_child(dup_display)
				player.update_hud()
				show_inventory(player)
				selecting = false
				placing = true
			elif itemlist_group == "weapons":
#				var packsize = 0
				if player.primaryGun != []:
					if current_list[inventory_y] == player.primaryGun[0]:
						pass
					elif player.secondaryGun != []:
						if current_list[inventory_y] == player.secondaryGun[0]:
							player.swap()
						else:
							player.equip(current_list[inventory_y], false, "primaryGun")
					else:
						player.equip(current_list[inventory_y], false, "primaryGun")
						
				elif player.secondaryGun != []:
					if current_list[inventory_y] == player.secondaryGun[0]:
						player.swap()
					else:
						player.equip(current_list[inventory_y], false, "primaryGun")
				else:
					player.equip(current_list[inventory_y], false, "primaryGun")
#				for item in player.pack:
#					if item.get_instance_ID() == current_list[inventory_y].get_instance_ID():
#						player.pack.equipped = true
#					packsize += 1
				show_inventory(player)
#				selecting = false

			elif itemlist_group == "armour":
				player.equip(current_list[inventory_y], false, "armour")
#				for item in player.pack:
#					if item.get_instance_ID() == current_list[inventory_y].get_instance_ID():
#						player.pack.equipped = true
#					packsize += 1
				show_inventory(player)
#				selecting = false