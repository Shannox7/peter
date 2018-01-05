extends Control
var shoplist = [[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]]]
#var displaylist = [[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]],[[],[],[],[],[]]]
var packlist = []
var buyback = []
var start = false
var weapon = preload("res://Guns.tscn").instance()
var x = 0
var y = 0
var menu = 0
var buydisplay
var selldisplay
var player
var Global
func _ready():
	Global = get_node("/root/Global")
	x = 0
	y = 0
	get_parent().get_node("selector").set_opacity(0)
	get_parent().get_node("selector_list").set_opacity(0)
	if start == false:
		for lists in shoplist:
			for list in lists:
				list.append(generate(get_parent().Tier))

func start():
	if start == false:
		show_inventory()
		start = true
	else:
		update_inventory()
	set_process_input(true)

func generate(Tier):
	var item = weapon.get_node(Tier).random()
	item.Global = Global
	item.generate(Tier)
	return item
	
func show_inventory():
	var xlist = get_parent().get_node("shopposition").get_pos().x - 50
	for lists in shoplist:
		var ylist = get_parent().get_node("shopposition").get_pos().y
		xlist += 50
		for list in lists:
			if list != []:
#			displaylist[lists][list].append(display)
				list[0].set_pos(Vector2(xlist, ylist))
				get_parent().add_child(list[0])
			ylist += 50
		update_inventory()
		
func update_inventory():
#	if inventory_x == 0:
#		itemlist_group = "weapons"
#	elif inventory_x == 1:
#		itemlist_group = "armour"
#	elif inventory_x == 2:
#		itemlist_group = "deployables"
#	elif inventory_x == 3:
#		itemlist_group = "guns and parts"
#	player = Player
	packlist.clear()
	get_parent().get_node("List").clear()
	if player.pack != []:
		for items in player.pack:
#			if items.is_in_group(itemlist_group):
#				var displayitems = items.duplicate()
#			if items.is_in_group("deployables"):
#				items.deactivate()
			packlist.append(items)
			get_parent().get_node("List").append_bbcode(str(items.name) +'\n')
		pack_display()
#	if inventory_y == null:
#		pass
#	elif inventory_y > current_list.size() - 1 and current_list != []:
#		inventory_y = current_list.size() - 1
#		pack_display(inventory_y)
#	elif current_list != []:
#		pack_display(inventory_y)
#		else:
#			selecting = false
#			inventory_y = null
			
func selector(selecting):
	if selecting:
		if menu == 0:
			get_parent().get_node("selector_list").set_opacity(0)
			get_parent().get_node("selector").set_opacity(1) 
			get_parent().get_node("selector").set_pos(Vector2(get_parent().get_node("shopposition").get_pos().x + 50 * x, get_parent().get_node("shopposition").get_pos().y + 50 * y))
			pack_display()
		if menu == 1:
#			print('whats wrong?')
			get_parent().get_node("selector").set_opacity(0) 
			get_parent().get_node("selector_list").set_opacity(1) 
			get_parent().get_node("selector_list").set_pos(Vector2(get_parent().get_node("listposition").get_pos().x, get_parent().get_node("listposition").get_pos().y + 14.5 * y))
			pack_display()
#			get_parent().get_node("selector").set_pos(Vector2(get_parent().get_node("Position2D 2").get_global_pos().x, 15 * y))
	else:
		x= 0
		y= 0
		get_parent().get_node("selector").set_opacity(0)
		get_parent().get_node("selector_list").set_opacity(0) 
		get_parent().start()

func pack_display():
	if menu == 0:
		get_parent().get_node("BuyLabel").clear()
		if buydisplay != null:
			buydisplay.free()
			buydisplay = null
		if shoplist[x][y] != []:
			buydisplay = shoplist[x][y][0].duplicate()
			buydisplay.set_pos(get_parent().get_node("BuyDisplay").get_pos())
			buydisplay.set_rot(get_parent().get_node("BuyDisplay").get_rot())
			get_parent().add_child(buydisplay)
			get_parent().get_node("BuyLabel").append_bbcode(str(shoplist[x][y][0].name) + "\n")
			for stats in shoplist[x][y][0].stats:
				get_parent().get_node("BuyLabel").append_bbcode(str(stats) + "\n")
	elif menu == 1:
		get_parent().get_node("SellLabel").clear()
		if selldisplay != null:
			selldisplay.free()
			selldisplay = null
		selldisplay = packlist[y].duplicate()
		selldisplay.set_pos(get_parent().get_node("SellDisplay").get_pos())
		selldisplay.set_rot(get_parent().get_node("SellDisplay").get_rot())
		get_parent().add_child(selldisplay)
		get_parent().get_node("SellLabel").append_bbcode(str(packlist[y].name) + "\n")
		for stats in packlist[y].stats:
			get_parent().get_node("SellLabel").append_bbcode(str(stats) + "\n")
func close():
	get_parent().get_node("BuyLabel").clear()
	get_parent().get_node("SellLabel").clear()
	get_parent().get_node("List").clear()
	if buydisplay != null:
		buydisplay.free()
		buydisplay = null
	if selldisplay != null:
		selldisplay.free()
		selldisplay = null
	selector(false)
	set_process_input(false)
	get_parent().shop = false
	
func _input(event):
#	if event.is_action_released("menu_right"):
#		if menu == 1:
#			menu = 0
#		else:
#			menu += 1
#		x = 0
#		y = 0
#		selector(true)
#	elif event.is_action_released("menu_left"):
#		if menu == 0:
#			menu = 1
#		else:
#			menu -= 1
#		x = 0
#		y = 0
#		selector(true)
	if menu == 0:
		if event.is_action_released("select_right"):
			if x == shoplist.size() - 1:
				x = 0
			else:
				x += 1
		elif event.is_action_released("select_left"):
			if x == 0:
				x = shoplist.size() - 1
			else:
				x -= 1 
		elif event.is_action_released("select_up"):
			if y == 0:
				y = shoplist[0].size() - 1
			else:
				y -= 1
		elif event.is_action_released("select_down"):
			if y == shoplist[0].size() - 1:
				y = 0
			else:
				y += 1
		selector(true)
	elif menu == 1:
		if event.is_action_released("select_up"):
			if y == 0:
				y = packlist.size() - 1
			else:
				y -= 1
		elif event.is_action_released("select_down"):
			if y == packlist.size() - 1:
				y = 0
			else:
				y += 1
		selector(true)
	if event.is_action_pressed("command"):
		close()
	if event.is_action_pressed("interact"):
		if menu == 0:
			if shoplist[x][y][0].value <= player.trade:
				player.trade -= shoplist[x][y][0].value
				shoplist[x][y][0].get_parent().remove_child(shoplist[x][y][0])
				player.pack.append(shoplist[x][y][0])
				shoplist[x][y].clear()
			update_inventory()
		elif menu == 1:
			buyback.append(packlist[y])
			player.trade += packlist[y].value
			var number = 0
			for items in player.pack:
				if items.get_instance_ID() == packlist[y].get_instance_ID():
					player.pack.remove(number)
				number += 1
			update_inventory()
	
