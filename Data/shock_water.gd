extends Node2D
var effect = preload("res://effects.tscn").instance()
var ignite = false

var burn_time = 30.0
# max burn time = 60

var damage = .1
#damage up to 1

var position
var fire
var consume = false
var myself
var size = 1
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	myself = weakref(self)
	# Called every time the node is added to the scene.
	# Initialization here
	pass
func red():
	get_node("body/Sprite").set_modulate(Color(255, 0 , 0))
	pass
func original_color():
	get_node("body/Sprite").set_modulate(Color(1, 1 , 1))
	pass
	
func stats():
	var burn_timed = round(burn_time/60 * 100)
	var damaged = round(damage/1 * 100)
	var stats = [["Damage", damaged], ["Shock Time", burn_timed]]
	return stats
	
func activate():
	get_node("body").set_layer_mask_bit(19, true)
#	get_node("body").set_layer_mask_bit(9, true)
	get_node("body").set_collision_mask_bit(9, true)
	position = get_global_pos()
	set_fixed_process(true)
	show()
	pass
	
func builder():
	pass
	
func hit(collider):
	if (collider.effect == "shock") and not ignite:
#		get_node("body").set_layer_mask_bit(1, false)
		get_node("body").set_layer_mask_bit(9, false)
#		set_fixed_process(true)
		ignite = true
		fire = effect.get_node("shock").duplicate()
		get_parent().add_child(fire)
		fire.set_global_pos(get_global_pos())
		fire.get_node("Area2D").set_scale(Vector2(get_scale().x, 1))
		fire.get_node("electricity").set_emission_half_extents(Vector2(get_scale().x * fire.get_node("electricity").get_emission_half_extents().x, fire.get_node("electricity").get_emission_half_extents().y))
#		fire.get_node("smoke").set_emission_half_extents(Vector2(get_scale().x * fire.get_node("smoke").get_emission_half_extents().x, fire.get_node("smoke").get_emission_half_extents().y))
#		fire.get_node("smoke").set_amount(fire.get_node("smoke").get_amount() * get_scale().x)
		fire.get_node("electricity").set_amount(fire.get_node("electricity").get_amount() * get_scale().x)

func consume(collider):
	if !weakref(collider).get_ref():
		pass
	elif collider.get_parent().consume == false:
		var scale = collider.get_parent().get_scale().x
		get_node("RayCast2D").get_collider().get_parent().call_deferred('queue_free')
		set_scale(Vector2(get_scale().x + scale, 1))
		set_global_pos(Vector2(position.x + ((20 * get_scale().x)/2) - 10, get_global_pos().y))
	consume = false
	pass

func _fixed_process(delta):
	if not ignite and not consume:
		if get_node("RayCast2D").is_colliding():
			if get_node("RayCast2D").get_collider() != null:
				if get_node("RayCast2D").get_collider().is_in_group("water"):
					consume = true
					call_deferred("consume", get_node("RayCast2D").get_collider())

	if ignite == true:
		burn_time -= delta
		if burn_time <= 0:
			fire.call_deferred("queue_free")
			call_deferred("queue_free")