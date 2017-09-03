extends KinematicBody2D
var bulletspeed = 0
var Gravity = 20
var gravitycounter = 20
var bullet
var countdown = 2
var flip_mod = 1
var damage = 0
var stopping_power = 0
var accuracy = 0
var distance = 1
#var distance_timer
var velocity
var bh = preload("res://effects.tscn")
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
		collider.hit(self)
		queue_free()
	else:
		queue_free()
		
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
	explosion.set_pos(get_global_pos())
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
	if countdown <= 0:
		queue_free()

func fade():
	opacity -= .1
	get_node("Sprite").set_opacity(opacity)
	drop_stat_reduction()
	if opacity <= 0:
		queue_free()

func colliding():
	if is_colliding():
		if get_collider().is_in_group("inanimate") or get_collider().is_in_group(side):
			effect("no_hit", false)
		else:
			if flip_mod == -1:
				flip_effect = true
			else:
				flip_effect = false
			effect(get_collider().get_parent(), true)

