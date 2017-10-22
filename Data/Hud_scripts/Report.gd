extends Control
var start = false
var Global
var reports = []
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	Global = get_node("/root/Global")
	set_process_input(true)
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func report(event, success):
	var report_dup = get_node("report/report_ui").duplicate()
	if success:
		report_dup.get_node("Name").set_text(event.get_ref().name + " - Success!")
	else:
		report_dup.get_node("Name").set_text(event.get_ref().name + " - Failed!")
	if event.get_ref().food > 0:
		report_dup.get_node("Resources").append_bbcode("Food: " + str(event.get_ref().food) + "\n")
	if event.get_ref().scrap > 0:
		report_dup.get_node("Resources").append_bbcode("Scrap: " + str(event.get_ref().scrap) + "\n")
	if event.get_ref().medicine > 0:
		report_dup.get_node("Resources").append_bbcode("Meds: " + str(event.get_ref().medicine) + "\n")
	var number = 0
	for npc in event.get_ref().occupents:
		if npc != null:
			var survivor_card = get_node("survivor_card").duplicate()
			survivor_card.set_pos(Vector2(report_dup.get_pos().x, report_dup.get_pos().y + (30 * number)))
			survivor_card.get_node("Label").set_text(npc.get_ref().name)
			survivor_card.get_node("Label1").set_text(npc.get_ref().job)
	#		survivor_cards.append(survivor_card)
			report_dup.add_child(survivor_card)
			survivor_card.show()
			number += 1
	reports.append(report_dup)
	report_dup.set_global_pos(get_node("report/report_ui").get_global_pos())
	get_node("report").add_child(report_dup)
	if reports.front() == report_dup:
		report_dup.show()
	pass

func _input(event):
	if reports != []:
		reports.front().show()
		if event.is_action_pressed("interact"):
			reports.front().free()
			reports.pop_front()
			pass