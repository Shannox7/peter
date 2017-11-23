extends StaticBody2D
var effect = preload("res://effects.tscn").instance()
var ignite = false
var burn_time = 5
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func hit(collider):
	if (collider.effect == "fire" or collider.effect == "explosive") and not ignite:
		set_layer_mask_bit(1, false)
		set_layer_mask_bit(2, false)
		set_fixed_process(true)
		ignite = true
		var fire = effect.get_node("Fire").duplicate()
		get_parent().add_child(fire)
		fire.set_global_pos(Vector2(get_parent().get_global_pos().x, get_parent().get_global_pos().y - 20))

func _fixed_process(delta):
	burn_time -= delta
	if burn_time <= 0:
		get_parent().call_deferred("queue_free")