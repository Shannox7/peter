extends Node2D

func start(item):
	var display = item.duplicate()
	display.set_mode(1)
	display.set_layer_mask_bit(10, false)

	display.set_rot(get_node("display_pos").get_rot())
	add_child(display)
	get_node("name").set_text(item.name)
	if not item.is_in_group("Weapons"):
		display.set_pos(get_node("display_pos").get_pos())
		get_node("amount").set_text("X" + str(item.amount))
		get_node("fundamental").append_bbcode(item.fundamental())
		if item.stats() != null:
			rating_display(item)
		get_node("description").append_bbcode(item.description())
	else:
		rating_display(item)
		display.set_pos(Vector2(get_node("display_pos").get_pos().x - item.get_node("body/barrel_tip").get_pos().x/2, get_node("display_pos").get_pos().y))
		get_node("fundamental").append_bbcode("Clip Size: " + str(item.clip_capacity) + "\n")
		if item.effect != null:
			get_node("fundamental").append_bbcode(str(item.effect) + " X" + str(item.effect_multiplier))
		if item.effect == null and item.trajectory != null:
			get_node("fundamental").append_bbcode(str(item.trajectory))
		elif item.trajectory != null:
				get_node("fundamental").append_bbcode(", " + str(item.trajectory)) 
	get_node("value").set_text("$" +str(item.value))
	
func rating_display(part):
	var pos = get_node("rate_bar_pos")
	var number = 0
	for list in part.stats():
		var rate_bar = get_node("rating").duplicate()
		get_node("rating_list").add_child(rate_bar)
		rate_bar.show()
		rate_bar.get_node("stat").set_text(list[0])
#		if list[1] == 0:
#			rate_bar.get_node("rating_bar/rating").set_scale(Vector2(100,6))
#		else:
		rate_bar.get_node("rating_bar/rating").set_scale(Vector2(list[1],6))
		
		rate_bar.set_global_pos(Vector2(pos.get_global_pos().x, pos.get_global_pos().y + (24 * number)))
		number += 1
	get_node("description").set_global_pos(Vector2(10, pos.get_global_pos().y + (24 * number)))
#	get_node("rating_list").get_children().back().get_node("Position2D").get_global_pos().y
