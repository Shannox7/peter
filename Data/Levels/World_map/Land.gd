extends Node2D
var controller
var reinforcements = 0
var AI = false
var buildings
var infantry = 50
var players = []
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	get_node("Label").set_text(str(infantry))
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func add(number):
	infantry += number
	get_node("Label").set_text(str(infantry))
	
func remove(number):
	infantry -= number
	get_node("Label").set_text(str(infantry))
	
func reinforcements():
	reinforcements += 1
	get_node("Label").set_text(str(infantry) + " + " + str(reinforcements))
	
func battle():
	infantry += reinforcements
	reinforcements = 0
	get_node("Label").set_text(str(infantry))