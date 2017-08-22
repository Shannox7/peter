extends Control
var listx = 0
var player
func _ready():
	set_process_input(true)

func selector():
	if listx == 0:
		pass
	else:
		get_node("Boxes/Selector").set_pos(get_node("Boxes/Box" + str(listx)).get_pos())

func close():
	player.command = false
	player.windows = false
	get_parent().remove_child(self)
func _input(event): 
	if event.is_action_pressed("select_right"):
		listx = 3
	elif event.is_action_pressed("select_left"):
		listx = 1
	elif event.is_action_pressed("select_up"):
		listx = 2
	elif event.is_action_pressed("select_down"):
		listx = 4
		
	if event.is_action_released("select_right"):
		listx = 3
		player.command("attack")
		close()
	elif event.is_action_released("select_left"):
		listx = 1
		player.command("retreat")
		close()
	elif event.is_action_released("select_up"):
		listx = 2
		player.command("follow")
		close()
	elif event.is_action_released("select_down"):
		listx = 4
		player.command("hold")
		close()
	selector()