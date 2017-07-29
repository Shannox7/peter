extends KinematicBody2D

const FLOOR_ANGLE_TOLERANCE = 46
export var WALK_SPEED = 150
export var PRONE_SPEED = 60
export var CROUCH_SPEED = 100
export var ACCELERATION = 20
export var DECCELERATION = 10
export var acceleration_modifier = 1
export var AIMSPEED = .05
#slopes V
const SLIDE_STOP_VELOCITY = 1.0 # One pixel per second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # One pixel
var on_air_time = 100
const STOP_FORCE = 1300
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 150
var knockback_velocity = Vector2()
var storedpower
const IDLE_SPEED = 10
const GRAVITY = 600.0
var JUMP = Vector2(0, 250)
var smalljump = Vector2(0, 200)
var velocity = Vector2()
var flipped = false
var is_prone = false

var pos
var playerArm
var playerHead
var landing
var grounded = false
var jump
var jumping
var ally_list = []
var inventory = false
var hold = false
func _ready():
	set_fixed_process(true)
	set_process_input(true)
	landing = get_node("Area2D")
	landing.connect("body_enter", self, "landed")
	landing.connect("body_exit", self, "airborne")
	storedpower = smalljump
	playerArm = get_node("Player/Arm")
	playerHead = get_node("Player/Head")

func landed(beneath):
	grounded = true
func airborne(beneath):
	grounded = false

func _input(event):
	if event.is_action_pressed("ui_down"):
		if is_prone == false:
			is_prone = true
			get_node("Player").prone(true)
			get_node("Player").flip(flipped)
			get_node("Player").anim = "prone_idle_r"
#		get_node("standing").set_trigger(true)
#		get_node("prone").set_trigger(false)

	if event.is_action_pressed("ui_up"):
		if is_prone == true:
#			set_global_pos(Vector2(get_pos().x, get_pos().y -10))
			is_prone = false
			get_node("Player").prone(false)
			get_node("Player").flip(flipped)
			get_node("Player").anim = "crouch_idle_r"
#			get_node("prone").set_trigger(true)
#			get_node("standing").set_trigger(false)
		else:
			jumping = true
	if jumping == true and (grounded == true or velocity.y <= .05 and velocity.y >= -.05) and event.is_action_released("ui_up"):
#		print('are we flying yet?')
		velocity.y -= storedpower.y
		storedpower = smalljump
		jumping = false
#		grounded = false
	elif event.is_action_released("ui_up"):
		storedpower = smalljump
		jumping = false
#		grounded = false

	
func _fixed_process(delta):
	
	if jumping == true and storedpower.y <= JUMP.y and Input.is_action_pressed("ui_up"):
		storedpower.y += 10
	elif storedpower.y >= JUMP.y and grounded:
		velocity.y -= JUMP.y
		storedpower = smalljump
		jumping = false
#	JUMP = Vector2(cos(get_rot()) * delta * flip_mod, -sin(get_rot()) * delta * JUMP.y * flip_mod)
#	storedpower = Vector2(cos(get_rot()) * delta * flip_mod, -sin(get_rot()) * delta * storedpower.y * flip_mod)
	 
	
	if velocity.y > 0.2 or velocity.y < -0.2 and (grounded == false):
		acceleration_modifier = 0.5
	else:
		acceleration_modifier = 1
	var force = Vector2(0, GRAVITY)
#	velocity.y += delta * GRAVITY
		
	var stop = true
	if Input.is_action_pressed("ui_left"):
		stop = false
		if flipped == false:
			get_node("Player").flip(true)
			flipped = true
			playerArm.set_rot(-playerArm.get_rot())
			playerHead.set_rot(-playerHead.get_rot())
		if is_prone != true or grounded == false:
			velocity.x = max(min(velocity.x - ACCELERATION * acceleration_modifier, -WALK_SPEED), -WALK_SPEED)
		elif is_prone == true:
			velocity.x = max(min(velocity.x - ACCELERATION * acceleration_modifier, -PRONE_SPEED), -PRONE_SPEED)
#		if (velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED):
#			force.x -= WALK_FORCE
#			stop = false

	elif Input.is_action_pressed("ui_right"):
		stop = false
		if flipped:
			get_node("Player").flip(false)
			flipped = false
			playerArm.set_rot(-playerArm.get_rot())
			playerHead.set_rot(-playerHead.get_rot())
		if is_prone != true or grounded == false:
			velocity.x = max(min(velocity.x + ACCELERATION * acceleration_modifier, WALK_SPEED), -WALK_SPEED)
		elif is_prone == true:
			velocity.x = min(velocity.x + ACCELERATION * acceleration_modifier, PRONE_SPEED)
		
		if (velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED):
			force.x += WALK_FORCE
		
	if (Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")):
		if is_prone != true:
			get_node("Player").anim = "run_r"
		elif is_prone == true:
			get_node("Player").anim = "prone_crawl_r"
			
	if (Input.is_action_pressed("ui_right") == false and Input.is_action_pressed("ui_left") == false):
		if velocity.x > 0:
			velocity.x = max(velocity.x - ACCELERATION * acceleration_modifier, 0)
		else:
			velocity.x = min(velocity.x + ACCELERATION * acceleration_modifier, 0)
		if is_prone != true:
			get_node("Player").anim = "idle_r"
		elif is_prone == true:
			get_node("Player").anim = "prone_idle_r"
	velocity += force*delta
	var motion = velocity*delta + knockback_velocity
	motion = move(motion)
	var floor_velocity = Vector2()
	
	if (is_colliding()):
		var n = get_collision_normal()
		
		if (rad2deg(acos(n.dot(Vector2(0, -1)))) < FLOOR_ANGLE_TOLERANCE):
			on_air_time = 0
			floor_velocity = get_collider_velocity()
			if (stop):
				var vsign = sign(velocity.x)
				var vlen = abs(velocity.x)
		
				vlen -= STOP_FORCE*delta
				if (vlen < 0):
					vlen = 0
				velocity.x = vlen*vsign
			acceleration_modifier = 1
			if Input.is_action_pressed("ui_left"):
				velocity.x = min(velocity.x - ACCELERATION * acceleration_modifier, -WALK_SPEED)
			elif Input.is_action_pressed("ui_right"):
				velocity.x = max(velocity.x + ACCELERATION * acceleration_modifier, WALK_SPEED)	

			
			if abs((rad2deg(acos(n.dot(Vector2(0, -1))))) - get_node("Player").get_rotd()) < .1 or (rad2deg(acos(n.dot(Vector2(0, -1))))) == 0:
				get_node("Player").set_rotd((rad2deg(acos(n.dot(Vector2(0, -1))))))
#				print("woop")
			elif get_collider().get_name() == "slope_left" and (rad2deg(acos(n.dot(Vector2(0, -1)))) * - 1) < get_node("Player").get_rotd():
				get_node("Player").rotate(-.1)
			elif get_collider().get_name() != "slope_left" and (rad2deg(acos(n.dot(Vector2(0, -1))))) > get_node("Player").get_rotd() and (rad2deg(acos(n.dot(Vector2(0, -1))))) >= 0:
				get_node("Player").rotate(.1)
			elif (rad2deg(acos(n.dot(Vector2(0, -1))))) == 0 and get_node("Player").get_rotd() > 0:
				get_node("Player").rotate(-.1)

		if (on_air_time == 0 and velocity.x == 0 and get_travel().length() < SLIDE_STOP_MIN_TRAVEL and abs(velocity.x) < SLIDE_STOP_VELOCITY and get_collider_velocity() == Vector2()):
			revert_motion()
			velocity.y = 0.0
		else:	
			motion = n.slide(motion)
			velocity = n.slide(velocity)
			move(motion)
	else:
		if get_node("Player").get_rotd() > 0 and grounded == false and velocity.y > 5:
			get_node("Player").rotate(-.05)
#			print("mmkay")
		elif get_node("Player").get_rotd() < 0 and grounded == false and velocity.y > 5:
			get_node("Player").rotate(.05)
#			print("yakay")
	if (floor_velocity != Vector2()):
		move(floor_velocity*delta) 
		
	on_air_time += delta
		
	if is_prone:
		get_node("Player/prone").set_trigger(false)
		get_node("Player/standing").set_trigger(true)
		get_node("Player/prone").set_pos(get_node("Player/AnimatedSprite").get_pos())
	else:
		get_node("Player/standing").set_trigger(false)
		get_node("Player/prone").set_trigger(true)
		get_node("Player/standing").set_pos(get_node("Player/AnimatedSprite").get_pos())
		
	if knockback_velocity.x != 0 or knockback_velocity.y != 0:
#		print(knockback_velocity)
		knockback_velocity.x = knockback_velocity.x - ACCELERATION
		knockback_velocity.y = knockback_velocity.y + ACCELERATION
		if knockback_velocity.x < ACCELERATION:
			knockback_velocity.x = 0
		if knockback_velocity.y >= 0:
			knockback_velocity.y = 0
#	armanim = ""
#	print (velocity.x)