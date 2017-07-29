extends Node2D
var Tier = "Tier_1"
var shop = false
var player
func _ready():
	connect("body_enter", self, "shop")
	connect("body_exit", self, "no_shop")
	get_node("Shop").set_pos(get_node("Sprite 2").get_pos())
	
func start():
	connect("body_enter", self, "shop")
	connect("body_exit", self, "no_shop")
	
func shop(collider):
	if collider.is_in_group("players"):
		set_process_input(true)
		collider.display("interact: ", "Enter shop")
		player = collider


func no_shop(collider):
	if collider.is_in_group("players"):
		collider.display(null, null)
		set_process_input(false)
	

func _input(event):
	if event.is_action_pressed("interact") and shop == false:
#		shopping = shop.get_node("Shop")
#		if shop.get_parent() != null:
#			shop.get_parent().remove_child(shop)
		get_node("Shop").player = player
		get_node("Shop").start()
		get_node("Shop").selector(true)
		disconnect("body_enter", self, "shop")
		disconnect("body_exit", self, "no_shop")
		no_shop(player)
		set_process_input(false)
		shop = true
	
	