extends "res://Zones.gd"
var loot_spawn = 5
var type = "food"
var icon = 6
# roads = 0
# grocery = 1
# department = 2
# weapons = 3
# residential = 4 
# residential small = 5
# small business = 6
# military = 7
# government = 8
# lab = 9

func _ready():
	if loaded == false:
		loaded = true
		initialize()
	pass


	
		
		