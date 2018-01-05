extends Node2D
var detect_list = []
var loaded = false
var start = false
var area

var anim_time = 3
var total_anim_time = 3
var anim_second = 1
var anim_second_subtracted = 1

var chased = false
func _ready():
	
	if start == false:
		start = true
		get_node("Area2D").connect("body_enter", self, "detect")
		get_node("Area2D").connect("body_exit", self, "no_detect")
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

func _input(event):
	if event.is_action_pressed("interact") and not chased:
#		get_parent().get_parent().get_node("player_pos").set_global_pos(get_node("Area2D/Position2D").get_global_pos())
		get_node("/root/Global").player.get_parent().remove_child(get_node("/root/Global").player)
		get_node("/root/Global").load_level(get_parent().road, self)

func chased():
	get_node("incoming").show()
#	get_node("closed").show()
#	get_node("opened").hide()
	chased = true
	set_fixed_process(true)

func opened():
	get_node("incoming").hide()
#	get_node("closed").hide()
#	get_node("opened").show()
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
#	if anim_second <= 0:
#		get_node("closed/AnimationPlayer").play(str(self.door_side) + "door shake")
#		get_node("closed/bang").play("banging on door")
#		anim_second_subtracted -= .1
#		anim_second = anim_second_subtracted
	get_node("incoming/Label").set_text("INCOMING! IN " + str(round(anim_time)))
	if anim_time <= 0:
		opened()
#		get_node("closed/bang").play("break door")
#		get_node("Particles2D").set_emitting(true)
		anim_second_subtracted = 1
		anim_second = anim_second_subtracted
		anim_time = total_anim_time
		set_fixed_process(false)
	pass


