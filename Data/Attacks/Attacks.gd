extends KinematicBody2D
var bulletspeed = 300
var Gravity = 60
var gravitycounter = 20
var bullet
var countdown = rand_range(0, 1)
var flip_mod = 1
var damage = 0
var stopping_power = 0
var accuracy = 0
var distance = .5
#var distance_timer
var velocity
var bh = preload("res://effects.tscn").instance()
var bullet_humanoid
var flip_effect
var drop = false
var random
var damage_fraction
var bulletspeed_fraction
var random_drop_range
var side
var opacity = 1
var explode_damage
var shrapnel
var pierce_chance
var richochet_chance
#query space instead of collider

var faction
var visual_effect

var effect = null
var effect_multiplier = 0

func initialize():
	set_fixed_process(true)
	damage_fraction = damage/100.0
	bulletspeed_fraction = bulletspeed/100
	bulletspeed += rand_range(bulletspeed_fraction * -10 , bulletspeed_fraction* 10)
	random_drop_range = rand_range(100, 200)

func drop_stat_reduction():
	if damage < damage_fraction:
		damage = 0 
	else:
		damage -= damage_fraction
	stopping_power = 0
	
func explode_effect(collider, hit):
	if hit:
		explode()
		queue_free()
	else:
		explode()
		queue_free()
		
func hit_and_explode_effect(collider, hit):
	if hit:
		collider.hit(self)
		explode()
		queue_free()
	else:
		explode()
		queue_free()
		
func hit_effect(collider, hit):
	if hit:
		blood()
		collider.hit(self)
		queue_free()
	else:
		queue_free()
		
func blood():
	var blood = bh.get_node("Blood_splatter").duplicate()
	blood.set_pos(get_collision_pos())
#	blood.set_scale(Vector2(1 * flip_mod, 1))

	get_parent().add_child(blood)
	blood.set_rot(blood.get_angle_to(get_pos()) - 3.14159/2)
#	blood.set_rotd(blood.get_rotd() * - 1)
	blood.set_emitting(true)

func loop(delta):
	velocity += Vector2(0, Gravity) * delta # Where gravity is some decently large number ( I use 600)
	set_rot(velocity.angle() - (3.14 / 2))
	move(velocity * delta)
	
func hit_pierce_effect(collider, hit):
	if hit:
		collider.hit(self)
		queue_free()
	else:
		queue_free()

func richochet_effect(collider, hit):
	if hit:
		collider.hit(self)
		queue_free()
	else:
		queue_free()

func explode():
#	pass
	var explosion = load("res://Explosives.tscn").instance().get_node("explosion").duplicate()
	explosion.damage = explode_damage
	explosion.shrapnelnumber = shrapnel
	explosion.faction = faction
	explosion.effect = effect
	explosion.effect_multiplier = effect_multiplier
	explosion.set_collision_mask_bit(faction.enemynumber, true)
#	explosion.set_collision_mask_bit(faction.enemynumber * 3, true)
	explosion.set_pos(get_collision_pos())
	get_parent().add_child(explosion)

#func grenade():
#	spawn_point.y - 10
#	grenade.throwx = max(min(abs(45 + rad2deg(Aimrot)) * 5, 200), 100)
#	grenade.throwy =  max(min(abs(45 + rad2deg(Aimrot)) * -6, -350), -500)
#	grenade.side = faction.side
#	grenade.set_collision_mask_bit(faction.enemynumber, true)
#	grenade.set_pos(spawn_point) 
#	grenade.flip_mod = flip_mod
#	level.add_child(grenade)
func ballistic_range(speed, gravity, initial_height):
#         Handling these cases is up to your project's coding standards

#        // Derivation
#        //   (1) x = speed * time * cos O
#        //   (2) y = initial_height + (speed * time * sin O) - (.5 * gravity*time*time)
#        //   (3) via quadratic:     [ignore smaller root]
#        //   (4) solution: range = x = (speed*cos O)/gravity * sqrt(speed*speed*sin O + 2*gravity*initial_height)    [plug t back into x=speed*time*cos O]

        var angle = get_rot()
# // no air resistence, so 45 degrees provides maximum range
        var cos_ang = cos(angle)
        var sin_ang = sin(angle)
        var t = (bulletspeed*sin_ang)/gravity + sqrt(bulletspeed*bulletspeed*sin_ang + 2*gravity*initial_height)/gravity
        var fire_range = (speed*cos_ang/gravity) * (speed*sin_ang + sqrt(speed*speed*sin_ang*sin_ang + 2*gravity*initial_height))
        print (" bullet_range time: " + str(t))
        return fire_range



#func canon_shot():
#	var t = bulletspeed*sin(45) + sqrt((bulletspeed * bulletspeed) * 45 + 2 * Gravity * -10)
#	var endvector = -10 + bulletspeed * t *sin(45) - .5 * Gravity * (t * t)
#	
#	print (t)
#	print (endvector)
#	pass
#func cannon_traj():
#	−0.4x2 + 10 == 0

func drop(delta):
	get_node("Sprite").set_offset(Vector2(0, 2))
	get_node("Sprite").set_centered(true)
	get_node("CollisionShape2D").set_pos(Vector2(0, 0))
	get_node("Sprite").rotate(-.1 * flip_mod)
	velocity.y += Gravity * delta
	Gravity += 2
	if bulletspeed < bulletspeed_fraction * 25:
		bulletspeed = bulletspeed_fraction * 25
	else:
		bulletspeed -= bulletspeed_fraction
	drop_stat_reduction()
	countdown -= .1
	if countdown <= 0:
		queue_free()

func fade():
	opacity -= .1
	get_node("Sprite").set_opacity(opacity)
	drop_stat_reduction()
	if visual_effect != null:
		visual_effect.set_opacity(opacity)
	if opacity <= 0:
		queue_free()

func colliding():
	if is_colliding():
		if get_collider().is_in_group("inanimate"):
			effect("no_hit", false)
		else:
			if flip_mod == -1:
				flip_effect = true
			else:
				flip_effect = false
			if get_collider().has_method("hit"):
				effect(get_collider(), true)
			else:
				effect(get_collider().get_parent(), true)

func fire():
	visual_effect.set_amount(500)
	get_node("Particles2D").set_color_phase_color(0, Color(50,0,0))
	get_node("Particles2D").set_color_phase_color(1, Color(0,0,0))
#	get_node("Particles2D").set_color(Color(0,0,0))
#	get_node("Sprite").set_modulate(Color(50,0,0))

func freeze():
	visual_effect.set_amount(200)
	get_node("Particles2D").set_color_phase_color(0, Color(5,5,5))
	get_node("Particles2D").set_color_phase_color(1, Color(0,0,50))

func shock():
#	get_node("Splash_bullet/Particles2D")
	visual_effect.set_amount(100)
	get_node("Particles2D").set_color_phase_color(0, Color(0,0,50))
	get_node("Particles2D").set_color_phase_color(1, Color(0,0,0))
	get_node("Sprite").set_modulate(Color(5,5,5))
	
	