extends StaticBody2D
var effect = preload("res://effects.tscn").instance()
var shock
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
	if (collider.effect == "shock") and not ignite:
		set_layer_mask_bit(1, false)
		set_layer_mask_bit(2, false)
		var shock = effect.get_node("shock").duplicate()
		get_parent().add_child(shock)
		set_fixed_process(true)
		ignite = true

func _fixed_process(delta):
	burn_time -= delta
	if burn_time <= 0:
		get_parent().call_deferred("queue_free")