extends "res://resource.gd"
var name = "Ammo"
var weight = 1
var scrap = 1
var food = 0
var medicine = 0

var ammo = 25
var amount = 1
var value = 10
func _ready():

	pass

func description():
	var a  = "Ammo: " + str(ammo) + "\n"
	var desc = "Ammo, use it to kill things."
	return a + desc