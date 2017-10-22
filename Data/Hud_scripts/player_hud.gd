extends Control
var icons = preload("res://Inventory_icons.tscn")

var bullet_list = []
var player

var Global

func _ready():
	set_process_input(true)
	
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

func update_hud():
	var scale = 100
	get_node("Points").set_text("Points: " + str(player.faction.points))
	if player.primaryGun != []:
		get_node("Label 2").set_text("Ammo: " + str(player.primaryGun[0].current_ammo) + "/" + str(player.primaryGun[0].current_clip))
		if player.reloading:
			get_node("Label 2").set_text("Reloading!: " + str(player.primaryGun[0].current_ammo) + "/" + str(player.primaryGun[0].current_clip))
	else:
		get_node("Label 2").set_text("Ammo: 0/0")
	get_node("Label 3").set_text("Food: " + str(Global.food))
	get_node("Label 4").set_text("Scrap: " + str(Global.scrap))
	get_node("Label 5").set_text("Medicine: " + str(Global.medicine))
	
func _input(event):
	pass