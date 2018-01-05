extends Camera2D
var faction
var following
var move_left = false
var move_right = false
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	faction = get_parent()
	following= faction.player_list.front()
	make_current()
	set_fixed_process(true)

	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _fixed_process(delta):
	var holding = false
	for player in faction.player_list:
		if following != player:
			if (player.get_global_pos().x < get_global_pos().x and following.get_global_pos().x > get_global_pos().x) or (player.get_global_pos().x > get_global_pos().x and following.get_global_pos().x < get_global_pos().x):
				holding = true 
		if get_global_pos().distance_to(player.get_global_pos()) < get_global_pos().distance_to(following.get_global_pos()):
			following = player

	if holding:
		set_global_pos(get_global_pos())
#	elif get_global_pos().distance_to(following.get_global_pos()) > 25:
#		set_follow_smoothing(2)
#		align()
#		set_global_pos(following.get_global_pos())
	else:
		set_global_pos(following.get_global_pos())
		
	get_node("right").set_global_pos(Vector2(get_camera_screen_center().x + get_viewport_rect().size.x/2, 0))
	get_node("left").set_global_pos(Vector2(get_camera_screen_center().x - get_viewport_rect().size.x/2, 0))
		