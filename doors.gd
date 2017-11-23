extends Node
var detect_list = []
var loaded = false
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
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