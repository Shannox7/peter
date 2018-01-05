extends "res://resource.gd"
var name = "Health"
var weight = 1
var scrap = 0
var food = 0
var medicine = 0

var health = 5
var value = 10
var amount = 1
func _ready():

	pass

func description():
	var h  = "Health: " + str(health) + "\n"
	var desc = "Health, bandage up those wounds before you end up dead and inflicting wounds on someone else!"
	return h + desc