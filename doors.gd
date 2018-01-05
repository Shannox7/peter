extends Node
var Global
var detect_list = []
var loaded = false
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var anim_time = 5
var total_anim_time = 5
var anim_second = 1
var anim_second_subtracted = 1

var chased = false
func _ready():
#	Global = get_parent().Global
	# Called every time the node is added to the scene.
	# Initialization here
	pass



func detect(collider):
	if not collider in detect_list:
		set_process_input(true)
		detect_list.append(collider)
func no_detect(collider):
	if collider in detect_list:
		detect_list.remove(detect_list.find(collider))
	if detect_list == []:
		set_process_input(false)
	pass

func enemy_chase():
	var go = false
	for enemy in get_parent().enemy_faction.attacker_list:
		if !enemy.get_ref():
			pass
		elif enemy.get_ref().chase == true:
			go = true
	return go

func chased():
	get_node("closed/barricade").show()
	get_node("closed").show()
	get_node("opened").hide()
	get_node("frame_closed").show()
	get_node("frame_open").hide()
	chased = true
	set_fixed_process(true)

func opened():
	get_node("closed/barricade").hide()
	get_node("closed").hide()
	get_node("opened").show()
	get_node("frame_open").show()
	get_node("frame_closed").hide()

	for enemy in get_node("/root/Global").chasing_list:
		enemy.get_ref().get_parent().remove_child(enemy.get_ref())
		get_parent().level.get_node("Enemy_faction").add_child(enemy.get_ref())
		enemy.get_ref().set_global_pos(get_node("Area2D/Position2D").get_global_pos())
		get_parent().level.chase_list.append(enemy.get_ref().myself)
	get_node("/root/Global").chasing_list.clear()

	chased = false
	
func _fixed_process(delta):
	anim_time -= delta
	anim_second -= delta
	if anim_second <= 0:
		get_node("closed/AnimationPlayer").play(str(self.door_side) + "door shake")
		get_node("closed/bang").play("banging on door")
		anim_second_subtracted -= .1
		anim_second = anim_second_subtracted
	if anim_time <= 0:
		opened()
		get_node("closed/bang").play("break door")
		get_node("Particles2D").set_emitting(true)
		anim_second_subtracted = 1
		anim_second = anim_second_subtracted
		anim_time = total_anim_time
		set_fixed_process(false)
	pass





