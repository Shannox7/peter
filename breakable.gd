extends Node2D
var health
var total_health
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	total_health = 40
	health = total_health
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func hit(collider):
	health -= collider.damage
	if health <= 0:
		queue_free()