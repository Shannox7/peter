extends KinematicBody2D
export var RUN_SPEED = 120
export var WALK_SPEED = 50 
export var ACCELERATION = 5
export var acceleration_modifier = 1


const GRAVITY = 200.0
var velocity = Vector2()

var flipped = false
var flip_mod = 1

var idle = false
var anim
var animNew
var passiveAnimNode
var timed
var random 

func _ready():
	set_fixed_process(true)
	timed = get_node("Timer")
	passiveAnimNode = get_node("AnimatedSprite")
	var wait_time = rand_range(1, 5)
	timed.set_wait_time(wait_time)
	timed.connect("timeout", self, "action")
#	add_collision_exception_with(get_parent().get_node("Pig"))
#	add_collision_exception_with(KinematicBody2D)
	
func action():
	idle = false
	random = int(rand_range(1, 4))
	if random == 1:
		idle = true
	elif random == 2:
		pass 
	elif random == 3:
		flip()
	

func flip():
	flipped = !flipped
	flip_mod = flip_mod * -1
	get_node("AnimatedSprite").set_flip_h(flipped)
		

func _fixed_process(delta):
	if velocity.y > 0.2 or velocity.y < -0.2:
		acceleration_modifier = 0.5
	else:
		acceleration_modifier = 1

	velocity.y += delta * GRAVITY
	

	
	var motion = velocity * delta
	motion = move(motion)
	
	if idle == true:
		velocity.x = 0
		anim = "idle"
	else:
		velocity.x = max(min(velocity.x + ACCELERATION * acceleration_modifier * flip_mod, WALK_SPEED), -WALK_SPEED)
		anim = "walk"
		timed.set_active(true)
		
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
		
	if anim != animNew:
		animNew = anim
		passiveAnimNode.play(anim)