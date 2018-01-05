extends Control
var player
var display
var inventory_x = 0
var inventory_y = 0

var itemlist_group = "craft"
var current_list = []

var item = null
var item_dup = null
var listx = 0
var crafting = [[],[],[]]
var crafting_display = [[],[],[]]

var dup_display
var base_item
var deploynumber
var placing = false
var selecting = false

func _ready():
	set_process_input(true)
	set_global_pos(Vector2(get_viewport().get_rect().size.x/2, get_viewport().get_rect().size.y/2))

func show_inventory(Player):
	player = Player
	current_list.clear()
	for label in get_node("lists").get_children():
		label.queue_free()
	if player.pack != []:
		var number = 0
		for items in player.pack:
			if items.is_in_group(itemlist_group):
				current_list.append(items)
				var new_label = get_node("item_label").duplicate()
				get_node("lists").add_child(new_label)
				new_label.set_text(str(items.name))
				new_label.set_pos(Vector2(new_label.get_pos().x, new_label.get_pos().y + number))
				number += new_label.get_size().y
	if current_list == []:
		player.comment("Nothing to craft with")
		close()
		
	elif inventory_y > current_list.size() - 1 and current_list != []:
		inventory_y = current_list.size() - 1
		pack_display(inventory_y)
	elif current_list != []:
		pack_display(inventory_y)
	else:
		selecting = false
#			inventory_y = null
	select()

func close():
	player.windows = false
	queue_free()
				
func display(part, position, display, list, parent):
	if display:
		if part.get_parent() != null:
			part.get_parent().remove_child(part)
		part.set_pos(get_node(str(parent) + "/" + str(position)).get_pos())
		get_node(str(parent)).add_child(part)
		for stats in part.stats:
			get_node(str(parent) + "/" + str(position) + "/" + str(position) + "_label").append_bbcode(str(stats) + "\n")

		
func pack_display(item):
	if item != null:
		if display != null and current_list != []:
			display.free()
		display = current_list[item].duplicate()
		display.set_pos(get_node("display_pos").get_pos())
		display.set_rot(get_node("display_pos").get_rot())
		add_child(display)
		get_node("Label").set_text(str(current_list[item].name))
#		for stats in current_list[item].stats:
#			get_node("Label").append_bbcode(str(stats) + "\n")
		selecting = true
	else:
		selecting = false
		


func select():
	if current_list != []:
		get_node("selector").show()
		get_node("selector").set_global_pos(get_node("lists").get_children()[inventory_y].get_global_pos())
	else:
		get_node("selector").hide()

func placing(selected):
	item = selected
	item_dup = item.duplicate()
	add_child(item_dup)
	place_selector()

func place_selector():
	get_node("selector").set_global_pos(get_node("boxes/box" + str(listx)).get_global_pos())
	if placing == true:
		item_dup.set_global_pos(get_node("boxes/box" + str(listx)).get_global_pos())


func _input(event):
	if not placing:
		if event.is_action_released("select_down"):
			if inventory_y >= current_list.size() - 1:
				inventory_y = 0
			else:
				inventory_y += 1
			show_inventory(player)
			select()
		elif event.is_action_released("select_up"):
			if inventory_y <= 0:
				inventory_y = current_list.size() - 1
			else:
				inventory_y -= 1
			show_inventory(player)

		elif event.is_action_pressed("interact"):
			placing = true
			placing(current_list[inventory_y])
	elif placing:
		if event.is_action_pressed("select_left"):
			if listx > 0:
				listx -= 1
			place_selector()
		elif event.is_action_pressed("select_right"):
			if listx < crafting.size() -1:
				listx += 1
			place_selector()
		elif event.is_action_pressed("interact"):
			var number = 0
			for list in crafting:
				if item in list:
					list.clear()
					crafting_display[number][0].queue_free()
					crafting_display[number].clear()
				number += 1
			if crafting[listx] != []:
				crafting[listx].clear()
				crafting_display[listx][0].queue_free()
			crafting[listx].append(item)
			crafting_display[listx].append(item_dup)
			item_dup.set_global_pos(get_node("boxes/box" + str(listx)).get_global_pos() + Vector2(12, 12))
			placing = false

	if event.is_action_pressed("reload"):
		close()
