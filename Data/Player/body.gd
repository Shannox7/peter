extends KinematicBody2D

func hit(collider):
	get_parent().hit(collider)