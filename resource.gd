extends Node2D
var is_equipped = false
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func equipped():
	pass

func drop():
	set_global_pos(Vector2(Global.player.get_global_pos().x, Global.player.get_global_pos().y - 20))
	set_rotd(0)
	Global.player.level.add_child(self)
	set_mode(0)
	set_layer_mask_bit(10, true)
	apply_impulse(Vector2(), Vector2(0, 5))
	if Global.on_supply_run:
		Global.supply_run_pack.remove(Global.supply_run_pack.find(self))
	else:
		Global.pack.remove(Global.pack.find(self))