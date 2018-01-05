extends Node2D
var enemy_list = []
var spawning = false
var spawn_move = false
var spawn_fade = false
var move_time = 2
var total_move_time = 2
var total_spawn_time = 3
var spawn_time = 3
var direction
var velocity = Vector2(0,1)
var opacity = 0
var start_opacity = true
func spawn_fade(zombie):
	spawn_fade = true
#	move_time =
	enemy_list.append(zombie)
	zombie.set_global_pos(get_node("spawn_pos").get_global_pos())
	zombie.set_opacity(0)
#	enemy.spawn_fade = true
	zombie.spawning = true
	zombie.start(false)
	set_fixed_process(true)

func spawn_fade_time(delta):
	if start_opacity == true:
		enemy_list[0].show()
		opacity += delta
		enemy_list[0].set_opacity(opacity)
		if opacity >= 1.0:
			opacity = 0.0
			start_opacity = false

			
func spawn_move(zombie):
	spawn_move = true
	enemy_list.append(zombie)
	zombie.set_global_pos(get_node("spawn_pos").get_global_pos())
	zombie.set_z(get_z() -1)
#	enemy.spawn_fade = true
	zombie.spawning = true
	zombie.start(false)
	set_fixed_process(true)
	pass
func spawn_crawl(enemy):
	pass
func spawn_climb(enemy):
	pass
func spawn_fall(enemy):
	pass
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
func move_to_pos(delta, anim):
	if not enemy_list[0].get_node("move").is_playing():
		enemy_list[0].get_node("move").play(anim)
	var distance = get_node("move_pos").get_pos() -get_node("spawn_pos").get_pos()
	var direction = velocity * (delta * (distance.y/total_move_time))
	enemy_list[0].move(direction)

func check_spawn():
	if spawn_time <= 0:
		spawn_time = total_spawn_time
		move_time = total_move_time
		start_opacity = true
		enemy_list[0].spawn_finish()
		enemy_list.pop_front()
		if enemy_list == []:
			set_fixed_process(false)
#### speed = distance/time
func _fixed_process(delta):
	spawn_time -= delta
	if spawn_fade:
		spawn_fade_time(delta)
		if spawn_time <= total_move_time:
			move_to_pos(delta, "walk")
			check_spawn()

			