extends KinematicBody2D

export var RUN_SPEED = 120
export var WALK_SPEED = 80 
export var ACCELERATION = 5
export var acceleration_modifier = 1

const GRAVITY = 200.0
export var total_health = 10
export var health = 10

var velocity = Vector2()
var rayNode
var player
var timer

var damage = 0

var flip_mod
var flipped = false
var hit_box
var viewarea
var tracking = false

var anim
var enemyAnimNode
var animNew


var health_bar_list = []
var healthpos
var healthBar
var dead
#create combustion awesomeness
func init_root(playerNode):
	player = playerNode

func _ready():
	set_fixed_process(true)
	rayNode = get_node("RayCast2D")
	timer = get_node("Timer")
	enemyAnimNode = get_node("AnimatedSprite")
	var wait_time = rand_range(1, 5)
	timer.set_wait_time(wait_time)
	viewarea = get_node("ViewArea")
	viewarea.connect("body_enter", self, "track")
	healthBar = get_node("healthBar")
	health_bars(total_health)
	tracking = false
	flip_mod = 1
	timer.connect("timeout", self, "man_flip")
	add_collision_exception_with(get_parent().get_node("Creep"))
	add_collision_exception_with(get_parent().get_node("Zombie"))
#func death():
#	print ("started at the bottom")
#	var deathTime = get_node("death")
#	deathTime.set_wait_time(5)
#	deathTime.connect("timeout", self, "set_free")
#	dead = true
	
#func destroy(anatomy):
#	var new_node = Node.new()
#	get_scene().add_child(new_node)
#	new_node.set_owner(get_scene(World))
#	anatomy.set_owner(get_scene(get_node(World)))
	
func health_bars(number):
	for bar in range(number - 1):
		var new_health_bar = healthBar.duplicate()
		new_health_bar.set_pos(Vector2(healthBar.get_pos().x * -bar, healthBar.get_pos().y))
#		print (new_health_bar.get_instance_ID())
		health_bar_list.append(new_health_bar)
		call_deferred("deferred", new_health_bar)
#	print (health_bar_list)
		
func deferred(defer):
		add_child(defer)
		
func death():
	set_fixed_process(false)
	queue_free()

func hit(dam):
	for hits in range(dam):
		health_bar_list[health - 2].play("health_empty")
		health -= 1
#	print ("shot meh")
	if health <= 0:
		death()
		
func track(collider):
	if collider.get_name() == "Peter":
		tracking = true
		player = collider
#		playerPos = player.get_pos()


func untrack(collider):
	if collider == player:
		tracking = false
		print("creep untrakc")	
		
func man_flip():
	if flipped == false:
		flipped = true
		flip()
	else:
		flipped = false
		flip()

func flip():
	if flipped == true:
		flip_mod = -1
		get_node("AnimatedSprite").set_flip_h(flipped)
	else:
		flip_mod = 1
		get_node("AnimatedSprite").set_flip_h(false)
	
func _fixed_process(delta):
	if velocity.y > 0.2 or velocity.y < -0.2:
		acceleration_modifier = 0.5
	else:
		acceleration_modifier = 1
	velocity.y += delta * GRAVITY
	
	if tracking:
		var go_to = (player.get_pos())
		rayNode.set_rot(get_angle_to(go_to) - 3.14159/2 * flip_mod)
		timer.set_active(false)
		velocity.x = max(min(velocity.x + ACCELERATION * acceleration_modifier * flip_mod, RUN_SPEED), -RUN_SPEED)
		if rayNode.get_rotd() >= 180:
			if flipped == true:
				flipped = false
				flip()
		elif rayNode.get_rotd() <= -180:
			if flipped == false:
				flipped = true
				flip()
	else:
		timer.set_active(true)
		velocity.x = max(min(velocity.x + ACCELERATION * acceleration_modifier * flip_mod, WALK_SPEED), -WALK_SPEED)
		anim = "creepin"
		
	var motion = velocity * delta
	motion = move(motion)
	
	if (is_colliding()):
		var what = get_collider()
#		print (what.get_name())
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
#		if what.get_name() == "Zombie":
#			man_flip()
#animations
	if anim != animNew:
		animNew = anim
		enemyAnimNode.play(anim)