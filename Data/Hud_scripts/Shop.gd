extends Control
var player
var shop
var res = preload("res://resource.tscn").instance()
var sell_display = null
var buy_display = null

var inventory_x = 0
var buy_x = 0
var buy_y = 0


var sell_x = 0
var sell_y = 0
var crafting_y = 0

var itemlist_group = "weapons"
var shop_itemlist_group = "weapons"

var current_list = []

var current_buy_list = []
var shop_inventory = []

var buy_back = []


var food = 0
var medicine = 0
var ammo = 0
var health_restore = null

var up_sell = .75

var primaryGun
var secondaryGun
var headArmour
var bodyArmour
var dup_display
var base_item

var selecting = false
var Global

func _ready():
	Global = get_node("/root/Global")
	set_pos(Vector2(get_viewport_rect().size.x/2, 200))
	

func start(Player, shopkeep):
	shop = shopkeep
	player = Player
	player.windows = true
	player.set_process_input(false)
#	player.walk_right = false
#	player.walk_left = false
	set_process_input(true)
	show_player_inventory()
	show_shop_inventory()

func close():
	set_process_input(false)
	player.windows = false
	player.set_process_input(true)
	get_parent().get_parent().remove_child(get_parent())
	shop.shopping = false
	
func generate_inventory():
	for number in range(20):
		var resource = res.get_children()[round(rand_range(4, res.get_children().size() - 1))].duplicate()
		var in_list = false
		for items in shop_inventory:
			if resource.name == items.name:
				items.amount += 1
				in_list = true
				break
		if in_list == false:
			resource.pick_up()
			shop_inventory.append(resource)
	generate_resource()
	generate_guns()
	pass

func generate_guns():
	for number in range(20):
		var resource = Global.Guns.get_node("Tier_1").get_children()[0].duplicate()
#		get_children()[round(rand_range(4, res.get_children().size() - 1))].duplicate()
#		var in_list = false
		resource.Global = Global
		resource.generate("Tier_1")
		resource.start()
		shop_inventory.append(resource)

func generate_resource():
	for number in range(20):
		var resource = res.get_children()[round(rand_range(1, 3))].duplicate()
		var in_list = false
		for items in shop_inventory:
			if resource.is_in_group("food") and items.is_in_group("food"):
				items.amount += resource.amount
				in_list = true
				break
			elif resource.is_in_group("medicine") and items.is_in_group("medicine"):
				items.amount += resource.amount
				in_list = true
				break
			elif resource.is_in_group("health") and items.is_in_group("health"):
				items.amount += resource.amount
				in_list = true
				break
			elif resource.is_in_group("ammo") and items.is_in_group("ammo"):
				items.amount += resource.amount
				in_list = true
				break
		if in_list == false:
			resource.pick_up()
			shop_inventory.append(resource)


func show_shop_inventory():
	if buy_x == 0:
		shop_itemlist_group = "Weapons"
	elif buy_x == 1:
		shop_itemlist_group = "Armour"
	elif buy_x == 2:
		shop_itemlist_group  = "Items"
	elif buy_x == 3:
		shop_itemlist_group = "Parts"
	elif buy_x == 4:
		shop_itemlist_group = "sold"
	elif buy_x == 5:
		shop_itemlist_group = "resource"

	get_node("buy_list").clear()
	get_node("buy_title").set_text(shop_itemlist_group)
	current_buy_list.clear()
	
	if shop_inventory != []:
		var number = 0
		for items in shop_inventory:
			if items.is_in_group(shop_itemlist_group):
				current_buy_list.append(items)

				if not items.is_in_group("guns and parts"):
					get_node("buy_list").add_item(str(items.name) + " X" + str(items.amount))
				elif items.is_equipped:
					get_node("buy_list").add_item(str(items.name) + " Equipped")
				else:
					get_node("buy_list").add_item(str(items.name))

		if current_buy_list != []:
			if buy_y > current_buy_list.size() - 1: 
				buy_y = current_buy_list.size() - 1
		else:
			buy_y = 0
		shop_display(buy_y, buy_display, current_buy_list, "buy_label", "display_pos1")
		select(current_buy_list, buy_y, "buy_lists")
		
func show_player_inventory():
	if sell_x == 0:
		itemlist_group = "Weapons"
	elif sell_x == 1:
		itemlist_group = "Armour"
	elif sell_x == 2:
		itemlist_group  = "Items"
	elif sell_x == 3:
		itemlist_group = "Parts"
	elif sell_x == 5:
		itemlist_group = "resource"
		
	get_node("sell_list").clear()
	get_node("sell_title").set_text(itemlist_group)
	
	current_list.clear()

	if player.pack != []:
		var number = 0
		for items in player.pack:
			if items.is_in_group(itemlist_group):
				current_list.append(items)
				
				if not items.is_in_group("guns and parts"):
					get_node("sell_list").add_item(str(items.name) + " X" + str(items.amount))
				elif items.is_equipped:
					get_node("sell_list").add_item(str(items.name) + " Equipped")
				else:
					get_node("sell_list").add_item(str(items.name))
					
		if current_list != []:
			if sell_y > current_list.size() - 1: 
				sell_y = current_list.size() - 1
		else:
			sell_y = 0
		pack_display(sell_y, sell_display, current_list, "sell_label", "display_pos")
		select(current_list, sell_y, "lists")
	
func remove_inventory(player):
	inventory_x = 0
	buy_x = 0
	buy_y = 0
	sell_x = 0
	sell_y = 0
	current_buy_list.clear()
	current_list.clear()
	set_process_input(false)
	selecting = false

func pack_display(item, display, list, label, display_pos):
	if sell_display != null:
		sell_display.free()
		sell_display = null
	if current_list != []:
		sell_display = Global.Card.duplicate()
		sell_display.start(current_list[item])
		call_deferred("add_child", sell_display)
		sell_display.set_pos(get_node("display_pos").get_pos())
		sell_display.get_node("value").set_text("$" + str(round(current_list[item].value - (current_list[item].value * up_sell))))
		selecting = true
	else:
		selecting = false

func shop_display(item, display, list, label, display_pos):
	if buy_display != null:
		buy_display.free()
		buy_display = null
	if current_buy_list != []:
		buy_display = Global.Card.duplicate()
		buy_display.start(current_buy_list[item])
		call_deferred("add_child", buy_display)
		buy_display.set_pos(get_node("display_pos1").get_pos())
		buy_display.get_node("value").set_text("$" + str(round(current_buy_list[item].value + (current_buy_list[item].value * up_sell))))
		selecting = true
	else:
		selecting = false
		
func select(list, y, label):
	if inventory_x == 1:
		if get_node("buy_list").get_item_count() > 0:
			get_node("buy_list").select(buy_y)
			get_node("buy_list").ensure_current_is_visible()
			
		get_node("greyed").set_pos(get_node("sell_inv").get_pos())
		get_node("sell_button").set_pressed(false)
		get_node("buy_button").set_pressed(true)
	else:
		if get_node("sell_list").get_item_count() > 0:
			get_node("sell_list").select(sell_y)
			get_node("sell_list").ensure_current_is_visible()
		get_node("greyed").set_pos(get_node("buy_inv").get_pos())
		get_node("sell_button").set_pressed(true)
		get_node("buy_button").set_pressed(false)

func buy():
	var item = current_buy_list[buy_y].duplicate()
	var full = false
	var money = true
	if not item.is_in_group("guns and parts"):
		item.amount = 1
	if round(current_buy_list[buy_y].value + (current_buy_list[buy_y].value * up_sell)) > player.trade:
		player.comment("I dont have enough to trade!")
		item.free()
	elif shop_itemlist_group == "resource":
		if item.is_in_group("food"):
			player.food += item.food
		elif item.is_in_group("medicine"):
			player.medicine += item.medicine
		elif item.is_in_group("ammo"):
			if player.current_ammo == player.ammo_capacity:
				full = true
			elif player.current_ammo + item.ammo < player.ammo_capacity:
				player.current_ammo += item.ammo
			else:
				player.current_ammo = player.ammo_capacity
		elif item.is_in_group("health"):
			if player.health == player.total_health:
				full = true
			elif item.health + player.health > player.total_health:
				player.health = player.total_health
			else:
				player.health += item.health
			player.health()
		if not full:
			player.trade -= round(current_buy_list[buy_y].value + (current_buy_list[buy_y].value * up_sell))
			if current_buy_list[buy_y].amount > 0:
				current_buy_list[buy_y].amount -= 1
			if current_buy_list[buy_y].amount <= 0:
				shop_inventory.remove(shop_inventory.find(current_buy_list[buy_y]))
		else:
			player.comment("I dont need any more " + str(item.name) + "!")
		item.free()
	else:
		player.trade -= round(current_buy_list[buy_y].value + (current_buy_list[buy_y].value * up_sell))
		if not item.is_in_group("guns and parts"):
			var in_pack = false
			for pack_item in player.pack:
				if pack_item.name == item.name:
					in_pack = true
					pack_item.amount += 1
					player.h.get_node("Player1").update_quick_select()
					item.free()
					break
			if in_pack == false:
				player.pack.append(item)
				player.check_ui_slots(item)
			if current_buy_list[buy_y].amount > 0:
				current_buy_list[buy_y].amount -= 1
			if current_buy_list[buy_y].amount <= 0:
				shop_inventory.remove(shop_inventory.find(current_buy_list[buy_y]))
		else:
			shop_inventory.remove(shop_inventory.find(current_buy_list[buy_y]))
			player.pack.append(current_buy_list[buy_y])
			item.free()

	show_player_inventory()
	show_shop_inventory()
	
func sell():
	var item = current_list[sell_y].duplicate()
	var full = false
#	var money = true
	
	if not item.is_in_group("guns and parts"):
		item.amount = 1
	if itemlist_group == "resource":
		if item.is_in_group("food"):
			player.food -= item.food
		elif item.is_in_group("medicine"):
			player.medicine -= item.medicine
		elif item.is_in_group("ammo"):
			player.current_ammo -= item.ammo

		if not full:
			player.trade += round(current_list[sell_y].value - (current_list[sell_y].value * up_sell))
			if current_list[sell_y].amount > 0:
				current_list[sell_y].amount -= 1
			if current_list[sell_y].amount <= 0:
				player.pack.remove(player.pack.find(current_list[sell_y]))
				player.h.get_node("Player1").update_quick_select()
	else:
		player.trade += round(current_list[sell_y].value - (current_list[sell_y].value * up_sell))
		if not item.is_in_group("guns and parts"):
			var in_pack = false
			for pack_item in shop_inventory:
				if pack_item.name == item.name:
					in_pack = true
					pack_item.amount += 1
					item.free()
					break
			if in_pack == false:
				shop_inventory.append(item)
			if current_list[sell_y].amount > 0:
				current_list[sell_y].amount -= 1
			if current_list[sell_y].amount <= 0:
				player.pack.remove(player.pack.find(current_list[sell_y]))
			player.h.get_node("Player1").update_quick_select()
		else:
			shop_inventory.append(current_list[sell_y])
			player.pack.remove(player.pack.find(current_list[sell_y]))
			item.free()

	show_player_inventory()
	show_shop_inventory()
	
func _input(event):
	if event.is_action_pressed(str(player.joy) + "select_up")or event.is_action_pressed(str(player.joy) + "ui_up"):
		if inventory_x == 0:
			if sell_y > 0:
				sell_y -= 1
				show_player_inventory()
		elif inventory_x == 1:
			if buy_y > 0:
				buy_y -= 1
				show_shop_inventory()
	if event.is_action_pressed(str(player.joy) + "select_down") or event.is_action_pressed(str(player.joy) + "ui_down"):
		if inventory_x == 0:
			if sell_y < current_list.size()-1:
				sell_y += 1
				show_player_inventory()
		elif inventory_x == 1:
			if buy_y < current_buy_list.size()-1:
				buy_y += 1
				show_shop_inventory()
	if event.is_action_pressed(str(player.joy) + "select_left") or event.is_action_pressed(str(player.joy) + "ui_left"):
		if inventory_x == 0:
			if sell_x > 0:
				sell_y = 0
				sell_x -= 1
				show_player_inventory()
		elif inventory_x == 1:
			if buy_x > 0:
				buy_y = 0
				buy_x -= 1
				show_shop_inventory()
	if event.is_action_pressed(str(player.joy) + "select_right")or event.is_action_pressed(str(player.joy) + "ui_right"):
		if inventory_x == 0:
			if sell_x < 5:
				sell_y = 0
				sell_x += 1
				show_player_inventory()
		elif inventory_x == 1:
			if buy_x < 5:
				buy_y = 0
				buy_x += 1
				show_shop_inventory()
		
	if event.is_action_pressed(str(player.joy) + "place"):
		if inventory_x == 0:
			inventory_x = 1
			select(current_buy_list, buy_y, "buy_lists")
	elif event.is_action_pressed(str(player.joy) + "L1"):
		if inventory_x == 1:
			inventory_x = 0
			select(current_list, sell_y, "lists")
			
	if event.is_action_pressed(str(player.joy) + "interact"):
		if inventory_x == 0:
			if current_list != []:
				sell()
		else:
			if current_buy_list != []:
				buy()
			
	if event.is_action_pressed(str(player.joy) + "command"):
		close()