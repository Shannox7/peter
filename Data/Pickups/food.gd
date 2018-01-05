extends "res://resource.gd"
var name = "Canned Food"
var weight = 1
var trade = 0
var food = 1
var medicine = 0
var value = 10
var amount = 1
func _ready():

	pass

func description():
	var f  = "Food: " + str(food) + "\n"
	var desc = "Food, necessary for life... and the dead, but they wouldnt like this."
	return f + desc