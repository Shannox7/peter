extends Node2D
var health = 300.0
var total_health = 300.0
#max health for walls 1000

var faction
var zone = null
var myself 
var dead = false
var grounded = true
var size = 2
var stats = []

func hit(collider):
	health -= collider.damage
	if health <= 0:
		call_deferred("queue_free")

func stats():
	var healthd = round(total_health/1000 * 100)
	stats = [["Health", healthd]]
	return stats

func activate():
	myself = weakref(self)

#	faction = get_parent()

#	get_node("body").set_layer_mask_bit(8, true)
	get_node("body").set_layer_mask_bit(9, true)
#	get_node("body").set_layer_mask_bit(0, true)
#	get_node("body").set_layer_mask_bit(14, true)

	get_node("body").set_layer_mask_bit(19, true)
	get_node("body").add_to_group(get_parent().side)
	get_node("body").set_layer_mask_bit(get_parent().sidenumber, true)
#	get_node("StaticBody2D").set_layer_mask_bit(11, true)
#	get_node("StaticBody2D").set_collision_mask_bit(9, true)
#	position = get_global_pos()
#	set_fixed_process(true)
	show()
	pass