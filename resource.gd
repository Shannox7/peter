extends Node2D
var is_equipped = false
var gravitate = false
var player = null
var speed = 200
var time = 5
var highlight = false
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func gravitate(p):
	set_layer_mask_bit(10, false)
	player = p
	set_mode(0)
	gravitate = true
	set_fixed_process(true)

func highlight(selecting):
	highlight = selecting
	pass

func pick_up():
	if get_parent() != null:
		get_parent().remove_child(self)
	set_mode(1)
	set_layer_mask_bit(10, false)
	is_equipped = false
	
func _fixed_process(delta):
	if gravitate == true:
		if !player.get_ref():
			queue_free()
		elif player == null:
			queue_free()
		else:
			time -= delta
			var target = player.get_ref().get_node("body").get_global_pos()
			var distance = target - get_global_pos()
			var direction = distance.normalized() # direction of movement
			if distance.length() > 1 and time > 0:
				set_linear_velocity(direction*speed)
			else:
				call_deferred("queue_free")
	elif highlight:
		set_scal(Vector2())
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func loot(building):
	var chance = 50
#	if building.size == "small":
#		chance += 10
#	elif building.size == "medium":
#		chance += 20
#	elif building.size == "big":
#		chance += 30
	
	var random = round(rand_range(0, 100))
	if random <= chance:
		var random_what = round(rand_range(0, 100))
		var ran = 100/get_children().size()
		for nodes in get_children():
			if random_what in range(0, ran):
				return(nodes.duplicate())
				break
			else:
				ran += 100/get_children().size()
	else:
		return null

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