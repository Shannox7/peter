extends StaticBody2D
var named = "Turret"
var name = "Turret"
var cost = 10
var build_time = 5



var target
#var grounded = false
var target_list = []
var hit = false
export var total_health = 10
var health
var rayNode
var raycast
var timer
var placed = false
#var bullet = preload("res://Bullets.tscn")
var attack = preload("res://Attacks.tscn")
var build = preload("res://Buildings.tscn")

var viewarea
var tracking
var dead = false

var head
var attack_ready = true

var reload
var cast = false
var anim

var random
var patrol = true
var attack_timer
var wait_time
var reloading
var stats = []

var enemy
var side
var sidenumber
var enemynumber
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

func builder():
	return build.instance().get_node("one_tile/Build")

func cast(collider):
	if collider.get_name() == "TileMap" or collider.get_name() == "Obstacles" or collider.get_name() == "slope_left":
		pass
	elif collider.is_in_group("enemies"):
		set_fixed_process(true)
#		print("cast")
		timer.stop()
		target_list.append(collider)
#		print (collider)
		target = target_list.front()
		track(target)
#	print(target_list)
func stop_cast(collider):
	var nothing
	if collider == target:
#		print('works')
		target = nothing
		target_list.clear()
		tracking = false
		patrol = false
		viewarea.connect("body_enter", self, "cast")
		head.set_rotd(0)
		set_fixed_process(false)
		patrol()
func red():
	get_node("head").set_modulate(Color(255, 0, 0))
	get_node("Body").set_modulate(Color(255, 0, 0))
func original_colour():
	get_node("head").set_modulate(Color(1, 1, 1))
	get_node("Body").set_modulate(Color(1, 1, 1))
	
func track(collider):
	tracking = true
#	enemy = target_list.front()
	viewarea.disconnect("body_enter", self, "cast")

func untrack(collider):
	if collider == target:
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
	var spawn_point = pos + get_node("head/gun").get_global_pos()
	for bullets in head.bullet_list.back():
		bullets.set_rotd(rad2deg(Aimrot) + rand_range(head.accuracy, -head.accuracy))
		bullets.set_pos(spawn_point)
		bullets.set_collision_mask(4)
		bullets.side = side
		get_parent().get_parent().add_child(bullets)
	head.shoot()
	attack_ready = false
	attack_timer.set_wait_time(head.fire_rate)
	if head.current_clip <= 0 and head.current_ammo > 0:
		reload()
	
func reload():
	attack_timer.stop()
	attack_timer.set_wait_time(head.reload_speed)
	head.reload()
	attack_timer.start()
func set_free():
	queue_free()
func deactivate():
#	set_fixed_process(false)
#	get_node("CollisionShape2D").set_trigger(true)
	set_z(1)

	
func activate(s, n, e, en):
	set_fixed_process(true)
	head.start()
	set_z(-1)
	enemy = e
	side = s
	enemynumber = en
	sidenumber = n
	add_to_group(s)
	set_layer_mask(n)
	set_collision_mask(n)
	set_layer_mask_bit(9, true)
	get_node("head/Area2D").set_collision_mask(n)
#	get_node("CollisionShape2D").set_trigger(false)
	viewarea.connect("body_enter", self, "cast")
	viewarea.connect("body_exit", self, "stop_cast")
	attack_timer.connect("timeout", self, "attack_flip")
	timer.connect("timeout", self, "patrol")
	timer.start()
	attack_timer.start()
	patrol()
	placed = true
func hit(collider):
	pass
func _fixed_process(delta):
#	if cast == true:
#		print ("casting")
#		var position = Vector2(enemy.get_pos().x, enemy.get_pos().y - enemy.get_pos().y)
#		raycast.set_cast_to(position)
#		if raycast.is_colliding():
#			if raycast.get_collider() == enemy:
#				tracking = true
#	if get_node("Area2D").is_colliding():
#		print(get_node("Area2D").get_collider())
#			if get_node("RayCast2D").get_coller() is_in_group("inanimate")
			
		
#		if (get_collider().get_name()== "TileMap" or get_collider().get_name()== "Obstacles") and tracking == false:  
#			set_fixed_process(false)
#	else:
#		move(velocity)
		
	if tracking:
		if target.dead:
			stop_cast(target)
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
			var go_to = (target.get_global_pos())
			head.set_rot(get_angle_to(go_to)- 3.14159/2)
#			timer.set_active(false)
			if abs(go_to.x - get_pos().x) <= 300 and attack_ready == true and head.current_clip > 0: 
				attack()
#				print ("track and attack")
#	if patrol == true:	
#		head.rotate(.1 * random)

