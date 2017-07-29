extends Node2D
#var BULLETSPEED = 500
var shrapnel = []
var shrapnelnumber = 0
var damage = 0
var stopping_power = 0
var distance = .5
var distance_timer
var velocity = Vector2()
var bh = preload("res://effects.tscn")
var targets = [] 
func _ready():
	connect("body_enter", self, "find")
#	distance_timer = get_node("Distance")
#	distance_timer.set_wait_time(distance)
#	distance_timer.connect("timeout", self, "hurt")
#	distance_timer.start()
func hit(collider):
	pass

func find(collider):
	if collider.is_in_group("enemies"):
		targets.append(collider)
	elif collider.is_in_group("explosives"):
		collider.blow()
#func hurt():
#	for enemies in targets:
#		if enemies == null:
#			pass
#		else:
#			velocity = Vector2(cos(get_angle_to(enemies.get_pos())), -sin(get_angle_to(enemies.get_pos())))
#			enemies.hit(self)
#	queue_free()



