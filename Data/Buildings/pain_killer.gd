extends "res://resource.gd"
var name = "Pain Killer"
var weight = 1
var scrap = 0
var food = 0
var medicine = 0

var health = 30.0
#max health = player_health

var amount = 1
var value = 10
func _ready():
	pass

func description():
	var desc = "Pain Killers, will kill the pain but will not heal any wounds."
	return desc

func stats():
	var healthd = round(health/100 * 100)
	var stats = [["Extra Health", healthd]]
	return stats

func fundamental():
	return "Adds extra health" + "\n"
	

func activate(player):
	if player.total_health - player.bonus_health < .5:
		pass
	elif health/player.total_health*100 > player.total_health:
		player.bonus_health = player.total_health
		player.health()
	else:
		player.bonus_health += health/player.total_health*100
		player.health()
#	player.h.get_node("Player1").update_quick_select()
#	if amount < 0:
#		player.pack.remove(player.pack.find(self))
#		player.quick_use[player.h.get_node("Player1").listx][0].free()
#		player.quick_use[player.h.get_node("Player1").listx] = []
	