extends Area2D
#var BULLETSPEED = 500
var shrapnel = []
var shrapnelnumber = 0
var damage = 0
var stopping_power = 8
var distance = .5
var distance_timer
var velocity = Vector2()
var bh = preload("res://effects.tscn")
var targets = [] 
var time = 1

func _ready():
	set_fixed_process(true)
	pass

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
func _fixed_process(delta):
	time -= 1
	if time <= 0:
		for bodies in get_overlapping_bodies():
			print(get_overlapping_bodies())
			if not bodies.get_name() == "TileMap":
				bodies.hit(self)
		queue_free()

