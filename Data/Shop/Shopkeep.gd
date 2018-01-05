extends Node2D
var Tier = "Tier_1"
var shop = preload("res://Trade.tscn").instance()
var player_list = []
var shopping = false
func _ready():
	shop.get_node("Trade").Global = get_node("/root/Global")
	shop.get_node("Trade").generate_inventory()
	connect("body_enter", self, "shop")
	connect("body_exit", self, "no_shop")

	
func shop(collider):
#	if collider.is_in_group("players"):
	set_process_input(true)
	collider.comment("interact: Enter shop")
	player_list.append(collider)


func no_shop(collider):
#	if collider.is_in_group("players"):
	collider.comment("")
	player_list.remove(player_list.find(collider))
	if player_list == []:
		set_process_input(false)
	

func _input(event):
	if shopping == false:
		for player in player_list:
			if event.is_action_pressed(str(player.joy) + "reload"):
				if shop.get_parent() != null:
					shop.get_parent().remove_child(shop)
				shopping = true
				get_parent().add_child(shop)
				shop.get_node("Trade").start(player, self)
				set_process_input(false)
	else:
		for player in player_list:
			if event.is_action_pressed(str(player.joy) + "reload"):
				player.comment("Someone is browsing")
	
	