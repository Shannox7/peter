extends Control
var player
var display
var inventory_x = 0
var inventory_y = 0

var crafting_y = 0
var itemlist_group = "Weapons"
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
var colour_revert = false
var colour = 1
func _ready():
	set_process_input(true)
	set_fixed_process(true)

func _fixed_process(delta):
	if not colour_revert:
		colour += delta
		if colour >= 1.5:
			colour_revert = true
	if colour_revert:
		colour -= delta
		if colour <= 0.5:
			colour_revert = false
	get_node("animate_crystal").set_modulate(Color(colour,colour,colour))

func start():
	player.set_process_input(false)
	if player.joy == 1:
		set_pos(Vector2(player.h.get_node("Player1").get_global_pos().x , player.h.get_node("Player1").get_global_pos().y + 100))
	else:
		set_pos(Vector2(player.h.get_node("Player1").get_global_pos().x, player.h.get_node("Player1").get_global_pos().y + 100))
	show_inventory()
	pass
	
func show_inventory():
	var secondary_title
	if inventory_x == 0:
		itemlist_group = "Weapons"
	elif inventory_x == 1:
		itemlist_group = "Armour"
	elif inventory_x == 2:
		itemlist_group = "Items"
	elif inventory_x == 3:
		itemlist_group = "Parts"
	get_node("list").clear()
	get_node("equipped1").set_text("")
	get_node("equipped2").set_text("")
	equipped_display(itemlist_group)
	get_node("title").set_text(itemlist_group)
#	get_node("title1").set_text(secondary_title)
	current_list.clear()
	if player.pack != []:
		var number = 0
		for items in player.pack:
			if items.is_in_group(itemlist_group):
				current_list.append(items)

				if not items.is_in_group("guns and parts"):
					get_node("list").add_item(str(items.name) + " X" + str(items.amount))
				elif items.is_equipped:
					get_node("list").add_item(str(items.name) + " Equipped")
				else:
					get_node("list").add_item(str(items.name))
#					get_node("amount_list").add_item("X" + str(items.amount))

		if current_list != []:
			if inventory_y > current_list.size() - 1: 
				inventory_y = current_list.size() - 1
		else:
			inventory_y = 0
		pack_display(inventory_y)
		select()
		
#func close_crafting(modded, modwith):
#	if modding[0] != [] and modded == true:
#		modding[0][0].equip_display(modding[0][0].barrel[0], "barrel")
#		modding[0][0].equip_display(modding[0][0].sight[0], "sight")
#		modding[0][0].equip_display(modding[0][0].special[0], "special")
#		modding[0][0].equip_display(modding[0][0].clip[0], "clip")
#		if modding[0][0].get_parent() != null:
#			modding[0][0].get_parent().remove_child(modding[0][0])
#		get_node("modding/special/special_label").clear()
#		get_node("modding/sight/sight_label").clear()
#		get_node("modding/clip/clip_label").clear()
#		get_node("modding/barrel/barrel_label").clear()
#		get_node("modding/body/body_label").clear()
#		modding = [[],[],[],[],[]]
#	if mod_with[0] != [] and modwith == true:
#		mod_with[0][0].equip_display(mod_with[0][0].barrel[0], "barrel")
#		mod_with[0][0].equip_display(mod_with[0][0].sight[0], "sight")
#		mod_with[0][0].equip_display(mod_with[0][0].special[0], "special")
#		mod_with[0][0].equip_display(mod_with[0][0].clip[0], "clip")
#		if mod_with[0][0].get_parent() != null:
#			mod_with[0][0].get_parent().remove_child(mod_with[0][0])
#		get_node("mod_with/special/special_label").clear()
#		get_node("mod_with/sight/sight_label").clear()
#		get_node("mod_with/clip/clip_label").clear()
#		get_node("mod_with/barrel/barrel_label").clear()
#		get_node("mod_with/body/body_label").clear()
#	mod_with = [[],[],[],[],[]]
	
func close():
	if placing:
		player.h.get_node("Player1").stop_placing()
	else:
		inventory_y = 0
		inventory_x = 0
		
		current_list.clear()
		set_process_input(false)
		set_fixed_process(false)
		selecting = false
		placing = false
		player.set_process_input(true)
		player.close()
	#	get_parent().get_parent().remove_child(get_paernt())
	#	if mod_with != [[],[],[],[],[]]:
	#		close_crafting(false, true)
	#	if modding != [[],[],[],[],[]]:
	#		close_crafting(true, false)
		
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
#	if display != null:
#		display.queue_free()
#		display = null
#	get_node("Label").clear()
#	get_node("Label1").clear()
#	get_node("Label2").clear()
	if primaryGun != null:
		primaryGun.queue_free()
		primaryGun = null
	if secondaryGun != null:
		secondaryGun.queue_free()
		secondaryGun = null
	if headArmour != null:
		headArmour.queue_free()
		headArmour = null
	if bodyArmour != null:
		bodyArmour.queue_free()
		bodyArmour = null
	if group == "Weapons":
		if player.primaryGun != []:
			get_node("equipped1").set_text("Equipped: Primary Gun")
			primaryGun = Global.Card.duplicate()
			primaryGun.start(player.primaryGun[0])
			add_child(primaryGun)
			primaryGun.set_pos(get_node("display_pos1").get_pos())
		if player.secondaryGun != []:
			get_node("equipped2").set_text("Equipped: Secondary Gun")
			secondaryGun = load("res://Card.tscn").instance().duplicate()
			secondaryGun.start(player.secondaryGun[0])
			add_child(secondaryGun)
			secondaryGun.set_pos(get_node("display_pos2").get_pos())
			
	elif group == "Armour":
		if player.headArmour != []:
			get_node("equipped1").set_text("Equipped: Head")
			headArmour = Global.Card.duplicate()
			headArmour.start(player.headArmour[0])
			add_child(headArmour)
			headArmour.set_pos(get_node("display_pos1").get_pos())
		if player.bodyArmour != []:
			get_node("equipped2").set_text("Equipped: Body")
			bodyArmour = Global.Card.duplicate()
			bodyArmour.start(player.bodyArmour[0])
			add_child(bodyArmour)
			bodyArmour.set_pos(get_node("display_pos2").get_pos())
			
#func rating_display(part, pos):
#	var number = 0
#	for list in part.stats():
#		var rate_bar = get_node("rating").duplicate()
#		get_node("rating_list").add_child(rate_bar)
#		rate_bar.show()
#		rate_bar.get_node("stat").set_text(list[0])
#		if list[1] == 0:
#			rate_bar.get_node("rating_bar/rating").set_scale(Vector2(100,6))
#		else:
#			rate_bar.get_node("rating_bar/rating").set_scale(Vector2(list[1],6))
#		
#		rate_bar.set_global_pos(Vector2(pos.get_global_pos().x, pos.get_global_pos().y + (23 * number)))
#		number += 1

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
	if display != null:
		display.free()
		display = null
	if current_list != []:
		display = Global.Card.duplicate()
		display.start(current_list[item])
		call_deferred("add_child", display)
		display.set_pos(get_node("display_pos").get_pos())
#		display = current_list[item].duplicate()
#		display.set_pos(get_node("display_pos").get_pos())
#		display.set_rot(get_node("display_pos").get_rot())
#		add_child(display)
#		get_node("Label").append_bbcode(str(current_list[item].name) + "\n")
#		if not current_list[item].is_in_group("guns and parts"):
#			get_node("Label").append_bbcode("Amount: " +str(current_list[item].amount) + "\n")
#		else:
#			rating_display(current_list[item], get_node("rate_bar_pos0"))
#		get_node("Label").append_bbcode("Sell Value: " +str(current_list[item].value) + " Weight: " + str(current_list[item].weight) + "\n")
#		get_node("Label").append_bbcode(current_list[item].description())
		selecting = true
	else:
		selecting = false
		
#func selector(selecting):
#	var selectors = [[get_node("select")],[get_node("select1")],[get_node("select2")],[get_node("select3")],[get_node("select4")]]
#	for lists in selectors:
#		lists[0].set_opacity(0)
#	if selecting:
#		selectors[crafting_y][0].set_opacity(1)

func select():
	if get_node("list").get_item_count() > 0:
		get_node("list").select(inventory_y)
		get_node("list").ensure_current_is_visible()


#func swap():
#	var location
#	if crafting_y == 0:
#
#		mod_with[0].push_front(modding[0][0])
#		modding[0].push_front(mod_with[0][1])
#		modding[0].pop_back()
#		mod_with[0].pop_back()
#
#		modding[0][0].equip(mod_with[0][0].barrel[0], "barrel")
#		modding[0][0].equip(mod_with[0][0].sight[0], "sight")
#		modding[0][0].equip(mod_with[0][0].clip[0], "clip")
#		modding[0][0].equip(mod_with[0][0].special[0], "special")
#		
#		mod_with[0][0].equip(modding[0][0].barrel[1], "barrel")
#		mod_with[0][0].equip(modding[0][0].sight[1], "sight")
#		mod_with[0][0].equip(modding[0][0].clip[1], "clip")
#		mod_with[0][0].equip(modding[0][0].special[1], "special")
#		
#		modding[0][0].unequip(modding[0][0].barrel[0], "barrel")
#		modding[0][0].unequip(modding[0][0].sight[0], "sight")
#		modding[0][0].unequip(modding[0][0].clip[0], "clip")
#		modding[0][0].unequip(modding[0][0].special[0], "special")
#		
#		mod_with[0][0].unequip(mod_with[0][0].barrel[0], "barrel")
#		mod_with[0][0].unequip(mod_with[0][0].sight[0], "sight")
#		mod_with[0][0].unequip(mod_with[0][0].clip[0], "clip")
#		mod_with[0][0].unequip(mod_with[0][0].special[0], "special")
#	else:
#		if crafting_y == 1:
#			location = "clip"
#		elif crafting_y == 2:
#			location = "special"
#		elif crafting_y == 3:
#			location = "sight"
#		elif crafting_y == 4:
#			location = "barrel"
#		modding[0][0].equip(mod_with[crafting_y][0], location)
#		mod_with[0][0].equip(modding[crafting_y][0], location)
#		modding[0][0].unequip(modding[crafting_y][0], location)
#		mod_with[0][0].unequip(mod_with[crafting_y][0], location)
#		mod_with[crafting_y].push_front(modding[crafting_y][0])
#		modding[crafting_y].push_front(mod_with[crafting_y][0])
#		mod_with[crafting_y].pop_back()
#		modding[crafting_y].pop_back()
#	close_crafting(true, true)
#	selector(false)
#	inventory_x = 2
#	show_inventory(player)
	
func _input(event):
	if placing == true:
		pass
	elif placing == false:
		if event.is_action_pressed(str(player.joy) + "select_right") or event.is_action_pressed(str(player.joy) + "ui_right"):
			if inventory_x < 2:
				inventory_x += 1
			show_inventory()
		elif event.is_action_pressed(str(player.joy) + "select_left") or event.is_action_pressed(str(player.joy) + "ui_left"):
			if inventory_x > 0:
				inventory_x -= 1
			show_inventory()
		elif event.is_action_pressed(str(player.joy) + "select_down") or event.is_action_pressed(str(player.joy) + "ui_down"):
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
			show_inventory()
			select()
		elif event.is_action_pressed(str(player.joy) + "select_up") or event.is_action_pressed(str(player.joy) + "ui_down"):
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
			show_inventory()
		elif event.is_action_pressed(str(player.joy) + "reload") and selecting == true:
#			if itemlist_group == "guns and parts":
#				var list = []
#				var dup
#				if modding != [[],[],[],[],[]]: 
#					if current_list[inventory_y].get_instance_ID() != modding[0][0].get_instance_ID():
#						if mod_with != [[],[],[],[],[]]:
#							close_crafting(false, true)
#						if current_list[inventory_y].is_equipped:
#							player.unequip(player.secondaryGun)
#						mod_with[0].append(current_list[inventory_y])
#						mod_with[1].append(mod_with[0][0].clip[0])
#						mod_with[2].append(mod_with[0][0].special[0])
#						mod_with[3].append(mod_with[0][0].sight[0])
#						mod_with[4].append(mod_with[0][0].barrel[0])
#						display(mod_with[0][0], "body", true, mod_with, "mod_with")
#						display(mod_with[0][0].barrel[0], "barrel", true, mod_with, "mod_with")
#						display(mod_with[0][0].sight[0], "sight", true, mod_with, "mod_with")
#						display(mod_with[0][0].special[0], "special", true, mod_with, "mod_with")
#						display(mod_with[0][0].clip[0], "clip", true, mod_with, "mod_with")
#					else:
#						print("are ya dumb?")
			if itemlist_group == "Weapons":
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
				show_inventory()

		elif event.is_action_pressed(str(player.joy) + "interact") and selecting:
			if inventory_x == 4:
				swap()
#			elif itemlist_group == "guns and parts":
#				var list = []
#				var dup
#				if modding != [[],[],[],[],[]]:
#					close_crafting(true, false)
#				if current_list[inventory_y].is_equipped:
#					player.unequip(player.primaryGun)
#				modding[0].append(current_list[inventory_y])
#				modding[1].append(modding[0][0].clip[0])
#				modding[2].append(modding[0][0].special[0])
#				modding[3].append(modding[0][0].sight[0])
#				modding[4].append(modding[0][0].barrel[0])
#				display(modding[0][0], "body", true, modding, "modding")
#				display(modding[0][0].barrel[0], "barrel", true, modding, "modding")
#				display(modding[0][0].sight[0], "sight", true, modding, "modding")
#				display(modding[0][0].special[0], "special", true, modding, "modding")
#				display(modding[0][0].clip[0], "clip", true, modding, "modding")
#				
			elif itemlist_group == "Items":
#				selecting = false
				placing = true
				player.h.get_node("Player1").placing(current_list[inventory_y])
#				if duplicatelist[0] != []:
#					var grow = 0
#					for item in duplicatelist[0]:
#						if item.get_instance_ID() == current_list[inventory_y].get_instance_ID():
#							duplicatelist[0].remove(grow)
#							duplicatelist[1][grow].queue_free()
#							duplicatelist[1].remove(grow)
#						grow += 1
#					var growing = 0
#					for lists in player.utility:
#						if lists != []:
#							for items in lists:
#								if items.get_instance_ID() == current_list[inventory_y].get_instance_ID():
#									player.utility[growing].clear()
#						growing += 1
#				base_item = current_list[inventory_y]
#				dup_display = current_list[inventory_y].duplicate()
#				duplicatelist[0].push_front(base_item)
#				duplicatelist[1].push_front(dup_display)
#				utility_display[8].append(dup_display)
#				dup_display.set_scale(Vector2(.5, .5))
#				dup_display.set_pos(get_node("boxes/box9").get_pos())
#				get_node("boxes").add_child(dup_display)
#				player.update_hud()
#				show_inventory(player)

			elif itemlist_group == "Weapons":
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
				show_inventory()

			elif itemlist_group == "Armour":
				player.equip(current_list[inventory_y], false, "Armour")
				show_inventory()
	if event.is_action_pressed(str(player.joy) + "command"):
		get_tree().set_input_as_handled()
		close()
		