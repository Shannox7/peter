extends StaticBody2D
var main
var dead = false
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	main = get_parent().get_parent().get_parent()
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func original_colour():
#	hit = false
#	set_modulate(Color(1, 1, 1))

func red():
#	main.get_node("hit_timer").start()
	if main.effect == null:
		get_node("Sprite").set_modulate(Color(255,0, 0))

func hit(collider):
	
#	if collider.effect != null and main.effect == null:
#		main.effect = collider.effect
#		if collider.effect == "freeze":
#			main.freeze(collider.effect_multiplier)
#		elif collider.effect == "fire":
#			main.burn(collider.effect_multiplier)
#		elif collider.effect == "shock":
#			main.shock(collider.effect_multiplier)
#	red()
	if collider.damage * 3 > main.health:
		var vel = collider.velocity * collider.stopping_power
		set_layer_mask_bit(main.faction.sidenumber, false)
		main.dismember(get_parent(), vel)
	collider.critical = true
	var dia = Global.Float.duplicate()
	main.level.add_child(dia)
	dia.set_global_pos(Vector2(get_parent().get_global_pos().x -50, get_parent().get_global_pos().y - 10))

	dia.critical()
	main.hit(collider)
#	if main.hit == false:
#		main.knockback_velocity.x = collider.velocity.x * collider.stopping_power
#		main.knockback_velocity.y = collider.velocity.y * collider.stopping_power
#
#	main.hit = true
#	main.health -= collider.damage * 2
#	if main.health <= 0:
		
#		main.head = null
#		main.death()
#	main.health()
