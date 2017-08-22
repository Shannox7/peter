extends KinematicBody2D

var side


func hit(collider):
	get_parent().hit(collider)