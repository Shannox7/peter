extends KinematicBody2D
var named = "Turret"
var name = "Turret"
var damage = 2
var stopping_power = 1
var fire_rate = 0.1
var clip_capacity = 10
var current_clip = 10
var ammo_capacity = 400
var current_ammo = 400
var reload_speed = 3
var distance = 1
var accuracy = .2
var fullauto = true

var GRAVITY = 300
var knockback_velocity = Vector2(0, 0)
var knockback
var attack_speed = 200
var target_list = []
var hit = false
export var total_health = 10
var health
var velocity = Vector2()
var rayNode
var raycast
var timer
#var bullet = preload("res://Bullets.tscn")
var enemy
var attack = preload("res://Attacks.tscn")
var ammo
var allyGun

var idle = false

var viewarea
var tracking
var healthBar
var dead = false

var head
var ai
var pos
var attack_ready = true
var flipbullet = 1

var reload
var cast = false
var anim
var allyAnimNode
var animNew
var placeable = true
var sight_pos
var random
var health_bar_list = []
var healthpos
var patrol = true
var attack_timer
var wait_time
var reloading
var deactivated = false
var buildable_obstructions = []
var stats = []
func _ready():

#	set_fixed_process(true)
	head = get_node("head")
	raycast = get_node("head/RayCast2D")
	timer = get_node("Timer")
	viewarea = get_node("head/Area2D")
#	viewarea.connect("body_enter", self, "cast")
#	viewarea.connect("body_exit", self, "stop_cast")
#	enemyAnimNode = get_node("AnimatedSprite")
#	healthBar = get_node("healthBar")
#	health_bars(total_health)
	attack_timer = get_node("Attack")
	attack_timer.set_wait_time(.5)
#	attack_timer.set_active(false)
	tracking = false
	health = total_health
#	patrol()
	stats = head.stats
func patrol():
	patrol = true
	random = rand_range(1, -1)
	var wait_time = rand_range(1, 5)
	timer.set_wait_time(wait_time)
	timer.start()

func cast(collider):
	if collider.get_name() == "TileMap" or collider.get_name() == "Obstacles" or collider.get_name() == "slope_left":
		pass
	elif collider.is_in_group("enemies"):
		set_fixed_process(true)
#		print("cast")
		timer.stop()
		target_list.append(collider)
#		print (collider)
		enemy = target_list.front()
		track(enemy)
#	print(target_list)
func stop_cast(collider):
	var nothing
	if collider == enemy:
#		print('works')
		enemy = nothing
		target_list.clear()
		tracking = false
		patrol = false
		viewarea.connect("body_enter", self, "cast")
		head.set_rotd(0)
		set_fixed_process(false)
		patrol()

func track(collider):
	tracking = true
#	enemy = target_list.front()
	viewarea.disconnect("body_enter", self, "cast")

func untrack(collider):
	if collider == enemy:
		tracking = false
#		print("untrakc")
		
func attack_flip():
	attack_ready = true
	attack_timer.set_wait_time(head.fire_rate)
	attack_timer.start()
func attack():
#	print("attacking")
	var Aimrot
	Aimrot = head.get_rot()
	var pos = Vector2(cos(Aimrot), -sin(Aimrot))
	var spawn_point = head.get_pos() + pos + get_global_pos()
	head.bullet_list.back().set_rot(head.get_rot())
	head.bullet_list.back().set_pos(spawn_point)
	get_parent().add_child(head.bullet_list.back())
	head.shoot()
	attack_ready = false
	attack_timer.set_wait_time(head.fire_rate)
	if head.current_clip <= 0 and head.current_ammo > 0:
		reload()
	else:
		print('click')
	
func reload():
	attack_timer.stop()
	attack_timer.set_wait_time(head.reload_speed)
	head.reload()
	attack_timer.start()
func set_free():
	free()
func deactivate():
	set_fixed_process(false)
	get_node("CollisionShape2D").set_trigger(true)
	if get_node("Area2D").is_connected("body_enter", self, "non_buildable") == false:
		get_node("Area2D").connect("body_enter", self, "non_buildable")
		get_node("Area2D").connect("body_exit", self, "buildable")  
#	timer.stop()
#	attack_timer.stop()
	set_z(1)
	deactivated = true
func non_buildable(collider):
	placeable = false
#	print(buildable_obstructions)
	buildable_obstructions.append(collider)
func buildable(collider):
	buildable_obstructions.pop_front()
#	print(buildable_obstructions)
	if buildable_obstructions == []:
		placeable = true
	
func activate():
	set_fixed_process(true)
	set_z(0)
	get_node("CollisionShape2D").set_trigger(false)
	viewarea.connect("body_enter", self, "cast")
	viewarea.connect("body_exit", self, "stop_cast")
	attack_timer.connect("timeout", self, "attack_flip")
	timer.connect("timeout", self, "patrol")
	timer.start()
	attack_timer.start()
	patrol()
	deactivated = false
func hit(collider):
	pass
func _fixed_process(delta):
	velocity.y += delta * GRAVITY
#	if cast == true:
#		print ("casting")
#		var position = Vector2(enemy.get_pos().x, enemy.get_pos().y - enemy.get_pos().y)
#		raycast.set_cast_to(position)
#		if raycast.is_colliding():
#			if raycast.get_collider() == enemy:
#				tracking = true
	if get_node("Area2D").is_colliding():
		print(get_node("Area2D").get_collider())
		
		
#		if (get_collider().get_name()== "TileMap" or get_collider().get_name()== "Obstacles") and tracking == false:  
#			set_fixed_process(false)
	else:
		move(velocity)
		
	if tracking:
		if enemy.dead:
			stop_cast(enemy)
#			target_list.pop_front()
#			enemy = target_list.front()
#			print(target_list)
#			if target_list != []:
#				track(enemy)
#			else:
#				tracking = false
#				pass
#		print("tracking")
		else:
			var go_to = (enemy.get_global_pos())
			head.set_rot(get_angle_to(go_to)- 3.14159/2)
#			timer.set_active(false)
			if abs(go_to.x - get_pos().x) <= 300 and attack_ready == true and head.current_clip > 0: 
				attack()
#				print ("track and attack")
	if patrol == true:	
		head.rotate(.1 * random)

