extends "res://Characters.gd"
var repair_list = []
var vehicle = true
var operators = []
var full = false
var operator
var Gun
var pick_up = false

var turbulance_timer = 5
var turbulance_count = 5

var hover_takeoff_time = 2
var take_off_velocity = 30
var take_off = false
var landed = false
var landing = false

func track(collider):
	if collider.get_parent().myself in target_list or collider.get_parent().myself in building_list or collider.get_parent().myself in low_priority_list:
		pass
	elif collider.get_parent().has_method("initialize"):
		if collider.get_parent().background == true:
			building_list.append(collider.get_parent().myself)
		else:
			target_list.append(collider.get_parent().myself)
	elif collider.get_parent().has_method("repairing"):
		low_priority_list.append(collider.get_parent().myself)
	else:
		target_list.append(collider.get_parent().myself)
		
func untrack(collider):
	if collider.get_parent().myself in target_list:
		target_list.remove(target_list.find(collider.get_parent().myself))
	elif collider.get_parent().myself in building_list:
		building_list.remove(building_list.find(collider.get_parent().myself))
	elif collider.get_parent().myself in low_priority_list:
		low_priority_list.remove(low_priority_list.find(collider.get_parent().myself))

func go_to(object):
	holding = false
	if object == null:
		holding = true
	else:
		raycast.set_rot(get_angle_to(object.get_global_pos()) - 3.14159/2)
		if abs(object.get_global_pos().x - get_pos().x) <= 10:
			holding = true

#func attack():
#	var Aimrot = Gun.get_rot() * flip_mod
#	var pos = Vector2(cos(Aimrot), -sin(Aimrot)) * flip_mod
#	var spawn_point = pos + Gun.get_node("barrel_tip").get_global_pos()
#	for bullets in range(Gun.bullets_inbullets):
#		bullets = Gun.bullettype()
#		if flip_mod == -1:
#			bullets.get_node("Sprite").set_flip_h(true)  
#			bullets.flip_mod = -1
#		bullets.set_rotd(rad2deg(Aimrot) + rand_range(Gun.accuracy, -Gun.accuracy))
#		bullets.set_collision_mask_bit(faction.enemynumber, true)
#		bullets.set_pos(spawn_point)
#		bullets.side = faction.side
#		level.add_child(bullets)
#
#	Gun.shoot()
#	attack_ready = false
#	if Gun.current_clip <= 0 and Gun.current_ammo > 0:
#		reload()
		
func orders(commands):
	attack = false
	hold = false
	if commands == "attack":
		attack = true
		if faction.side == "allies":
			for obj in level.objective_list:
				if obj.get_ref().side != faction.side:
					objective = obj.get_ref().positions[obj.get_ref().positions.size() - 1]
					break
		elif faction.side == "enemies":
			for obj in level.objective_list:
				if obj.get_ref().side != faction.side:
					objective = obj.get_ref().positions[0]
	elif commands == "hold":
		hold = true

func flip_check():
	if raycast.get_rotd() < -90  and flipped == false:
		flipped = true
		flip(true)
	elif raycast.get_rotd() > -90 and flipped == true:
		flipped = false
		flip(false)

		
func death():
	dead = true
	faction.vehicle_list.remove(faction.vehicle_list.find(myself))
	for npc in operators:
		if npc == null:
			pass
		elif !npc.get_ref():
			pass
		else:
			if npc.get_ref().get_parent() == get_node("body"):
				npc.get_ref().swap()
				npc.get_ref().get_parent().remove_child(npc.get_ref())
#					npc.hold_order("add")
				npc.get_ref().defending = false
				npc.get_ref().in_defence = false
				faction.add_child(npc.get_ref())
				if npc.get_ref().myself == operators[0]:
					npc.get_ref().set_global_pos(get_node("body/driver_pos").get_global_pos())
				else:
					self.turret.deactivate()
					npc.get_ref().set_global_pos(get_node("body/gunner_pos").get_global_pos())
				npc.get_ref().set_fixed_process(true)
				npc.get_ref().flip(flipped)
			else:
				npc.get_ref().defending = false
				npc.get_ref().orders("attack")
			
#	for builders in repair_list:
#		if not builders.get_ref().dead:
#			builders.get_ref().build()
	if spawn_home != null:
		spawn_home.get_ref().spawns.remove(spawn_home.get_ref().spawns.find(myself))
#	call_deferred("queue_free")

func plane_attack(targetlist):
	var target = targetlist.front().get_ref()
	if !target:
		target_list.pop_front()
	elif target.dead:
		target_list.pop_front()
	else:
		var targeting = (target.get_node("body").get_global_pos())
		if rad2deg(get_node("body/turret_pos").get_angle_to(targeting) - 3.14159/2) <= 30 and rad2deg(get_node("body/turret_pos").get_angle_to(targeting) - 3.14159/2) >= -30:
			Gun.set_rot(get_node("body/turret_pos").get_angle_to(targeting)- 3.14159/2)
			operator.head.set_rot(Gun.get_rot())
			if get_global_pos().distance_to(targeting) <= (Gun.bulletspeed * Gun.distance) * .95:
				if attack_ready == true and Gun.current_clip > 0: 
					fire()
		else:
			Gun.set_rotd(0)
			operator.head.set_rotd(0)

func airborne(delta):
	turbulance_timer -= delta
	if turbulance_timer <= 0:
		velocity.y += rand_range(rand_range(-20, -10), rand_range(20, 10))
		turbulance_count -= delta
		if turbulance_count <= 0:
			turbulance_count = 5
			turbulance_timer = 5
				
	if grounded and velocity.y > -WALK_SPEED/2:
		velocity.y -= ACCELERATION


func hover(targetlist):
	var target = targetlist.front().get_ref()
	if !target:
		target_list.pop_front()
	elif target.dead:
		target_list.pop_front()
	else:
		var targeting = (target.get_node("body").get_global_pos())
		if get_global_pos().distance_to(targeting) <= 200 and operators[1] != null:
			holding = true
		elif operators[1] != null:
			raycast.set_rot(get_angle_to(targeting) - 3.14159/2)
		else:
			pick_up()
	
#	else:
#		operator.head.set_rotd(0)
	

func patrol():
	patrol = true
	for obj in level.objective_list:
		if obj.get_ref().side == faction.side:
			if faction.side == "allies":
				objective = obj.get_ref()
				break
			else:
				objective = obj.get_ref()

func hover_take_off():
	holding = true
	if grounded and velocity.y > -WALK_SPEED/2:
		velocity.y -= ACCELERATION
		if jump_l.get_global_pos().distance_to(jump_l.get_collision_point()) > 100:
			holding = false
			take_off = false

func gravity_check(delta):
	if velocity.y <= 0:
		velocity.y += GRAVITY * delta
	

func hover_air_moving():
	if holding:
		if abs(velocity.x) > 0:
			velocity.x -= DECCELERATION * sign(velocity.x)
			if abs(velocity.x) < 5:
				velocity.x = 0
		if abs(get_node("body").get_rotd()) > 1:
			get_node("body").rotate(.05 * flip_mod)
	else:
		if abs(velocity.x) < WALK_SPEED:
			velocity.x += ACCELERATION * flip_mod
		else:
			 velocity.x -= 10 * sign(velocity.x)
		anim = "run"
		if abs(get_node("body").get_rotd()) > -25 and abs(get_node("body").get_rotd()) < 25:
			get_node("body").rotate(-.05 * flip_mod)

	
func air_moving():
	if hold or holding:
		if abs(velocity.x) > 0:
			velocity.x -= DECCELERATION * sign(velocity.x)
			if abs(velocity.x) < 5:
				velocity.x = 0

	elif abs(velocity.x) < WALK_SPEED:
		velocity.x += ACCELERATION * flip_mod
	else:
		 velocity.x -= 10 * sign(velocity.x)
	anim = "run"
	
func air_die(delta):
	if is_colliding():
		print("colliding")
		var explode = load("res://Explosives.tscn").instance().get_node("explosion").duplicate()
		explode.set_global_pos(get_global_pos())
		explode.shrapnel = 50
		faction.add_child(explode)
		call_deferred("queue_free")

	else:
		GRAVITY += 1
		velocity.y = GRAVITY * delta
		move(velocity)
	
func pick_up():
	for obj in level.objective_list:
		if obj.get_ref().side == faction.side:
			if side == "allies":
				objective = obj.get_ref()
				break
			else:
				objective = obj.get_ref()
	raycast.set_rot(get_angle_to(objective.get_global_pos()) - 3.14159/2)
	if get_global_pos().distance_to(objective.get_global_pos()) <= 400:
		land()
		if landed == true:
			occupency()
			if full:
				pick_up = false
				landed = false
				take_off = true

func land():
	if velocity.y < WALK_SPEED:
		velocity.y += ACCELERATION
	if is_colliding():
		velocity = Vector2()
		landed = true

func solve_ballistic_arc(proj_pos, proj_speed, target, gravity):

#        // Handling these cases is up to your project's coding standards
#        Debug.Assert(proj_pos != target && proj_speed > 0 && gravity > 0, "fts.solve_ballistic_arc called with invalid data");

#        // C# requires out variables be set
        var s0
        var s1

#        // Derivation
#        //   (1) x = v*t*cos O
#        //   (2) y = v*t*sin O - .5*g*t^2
#        // 
#        //   (3) t = x/(cos O*v)                                        [solve t from (1)]
#        //   (4) y = v*x*sin O/(cos O * v) - .5*g*x^2/(cos^2 O*v^2)     [plug t into y=...]
#        //   (5) y = x*tan O - g*x^2/(2*v^2*cos^2 O)                    [reduce; cos/sin = tan]
#        //   (6) y = x*tan O - (g*x^2/(2*v^2))*(1+tan^2 O)              [reduce; 1+tan O = 1/cos^2 O]
#        //   (7) 0 = ((-g*x^2)/(2*v^2))*tan^2 O + x*tan O - (g*x^2)/(2*v^2) - y    [re-arrange]
#        //   Quadratic! a*p^2 + b*p + c where p = tan O
#        //
#        //   (8) let gxv = -g*x*x/(2*v*v)
#        //   (9) p = (-x +- sqrt(x*x - 4gxv*(gxv - y)))/2*gxv           [quadratic formula]
#        //   (10) p = (v^2 +- sqrt(v^4 - g(g*x^2 + 2*y*v^2)))/gx        [multiply top/bottom by -2*v*v/x; move 4*v^4/x^2 into root]
#        //   (11) O = atan(p)
        proj_speed /= 100

        var diff = target - proj_pos
        var diffXZ = diff.x
        var groundDist = diffXZ

        var speed2 = proj_speed*proj_speed
        var speed4 = (proj_speed*proj_speed*proj_speed*proj_speed)
        var y = diff.y
        var x = diff.x
        var gx = gravity*x

        var root = speed4 - gravity*(gravity*x*x + 2*y*speed2)
        print(root)
        print(x)
#        // No solution
#        if (root < 0):
#            return 0

        root = sqrt(root)

        var lowAng = atan2(speed2 - root, gx)
        var highAng = atan2(speed2 + root, gx)
#		if numSolutions != highAng ? 2:
#			else: 
#				numSolutions = 1

#        var groundDir = diffXZ.normalized()
#        s0 = groundDir*cos(lowAng)*proj_speed + y*sin(lowAng)*proj_speed
#        if (numSolutions > 1):
        proj_speed *= 100
        s1 = x*cos(highAng)*proj_speed + y*sin(highAng)*proj_speed
        print(s1)
        return s1

#
#    // Solve firing angles for a ballistic projectile with speed and gravity to hit a target moving with constant, linear velocity.
#    //
#    // proj_pos (Vector3): point projectile will fire from
#    // proj_speed (float): scalar speed of projectile
#    // target (Vector3): point projectile is trying to hit
#    // target_velocity (Vector3): velocity of target
#    // gravity (float): force of gravity, positive down
#    //
#    // s0 (out Vector3): firing solution (fastest time impact) 
#    // s1 (out Vector3): firing solution (next impact)
#    // s2 (out Vector3): firing solution (next impact)
#    // s3 (out Vector3): firing solution (next impact)
#    //
#    // return (int): number of unique solutions found: 0, 1, 2, 3, or 4.

func artillary_fire():
	attack_ready = false
	fire_ready.stop()
#	h.get_node("Player1").shoot(self)
	var Aimrot = arm_r.get_rot() * flip_mod
	var pos = Vector2(cos(Aimrot), -sin(Aimrot)) * flip_mod
	var spawn_point = pos + Gun.get_node("body/barrel_tip").get_global_pos()

	for bullets in range(Gun.bullets_inbullets):
		bullets = Gun.bullettype()
		bullets.faction = faction
		if flip_mod == -1:
			bullets.get_node("Sprite").set_flip_h(true)  
			bullets.flip_mod = -1
		bullets.set_rotd(rad2deg(Aimrot) + rand_range(Gun.accuracy, -Gun.accuracy))
		bullets.set_collision_mask_bit(faction.enemynumber, true)
		bullets.set_pos(spawn_point)
		bullets.side = faction.side
		level.add_child(bullets)
	Gun.shoot()
	armanim = "Shoot"
	fire_ready.set_wait_time(Gun.fire_rate)
	fire_ready.start()
	if Gun.current_clip <= 0 and Gun.current_ammo > 0:
		reload()
		
func artillary_attack(targetlist):
	var target = targetlist.front().get_ref()
	if !target:
		target_list.pop_front()
	elif target.dead:
		target_list.pop_front()
	else:
		var targeting = (target.get_node("body").get_global_pos())
		Gun.set_rot(solve_ballistic_arc(get_global_pos(), Gun.bulletspeed, targeting, GRAVITY))
			#if rad2deg(get_node("body/turret_pos").get_angle_to(targeting) - 3.14159/2) <= 45 and rad2deg(get_node("body/turret_pos").get_angle_to(targeting) - 3.14159/2) >= -45:
#			Gun.set_rot(get_node("body/turret_pos").get_angle_to(targeting)- 3.14159/2)
#			operator.head.set_rot(Gun.get_rot())
#		if get_global_pos().distance_to(targeting) <= (Gun.bulletspeed * Gun.distance) * .95:
		holding = true
		if attack_ready == true and Gun.current_clip > 0: 
			artillary_fire()

			
func tank_attack(targetlist):
	var target = targetlist.front().get_ref()
	if !target:
		target_list.pop_front()
	elif target.dead:
		target_list.pop_front()
	else:
		var targeting = (target.get_node("body").get_global_pos())
		if rad2deg(get_node("body/turret_pos").get_angle_to(targeting) - 3.14159/2) <= 45 and rad2deg(get_node("body/turret_pos").get_angle_to(targeting) - 3.14159/2) >= -45:
			Gun.set_rot(get_node("body/turret_pos").get_angle_to(targeting)- 3.14159/2)
			operator.head.set_rot(Gun.get_rot())
			if get_global_pos().distance_to(targeting) <= (Gun.bulletspeed * Gun.distance) * .95:
				holding = true
				if attack_ready == true and Gun.current_clip > 0: 
					fire()
		else:
			Gun.set_rotd(0)
			operator.head.set_rotd(0)
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
