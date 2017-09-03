extends Node2D
var side = ""
var capturing = ""
var ally_control = []
var enemy_control = []
var opacity = .5
var red
var capture_time_total = 10.0
var capture_time = 0.0
var total_point_time = 10
var point_time = 10
var points = 5

var buildings = []
var constructions = []
var positions = []
var background_full = false
var foreground_full = false

var level

func _ready():
	level = get_parent().get_parent()
	positions = get_node("Position2D").get_children()
	set_fixed_process(true)
	get_node("Area2D").connect("body_enter", self, "control")
	get_node("Area2D").connect("body_exit", self, "no_control")
	get_node("Area2D").connect("area_enter", self, "control")
	get_node("Area2D").connect("area_exit", self, "no_control")
	pass

func check_full():
	background_full = true
	foreground_full = true
	for pos in positions:
		if not pos.background:
			background_full = false
			break
			
	for pos in positions:
		if not pos.foreground:
			foreground_full = false
			break
		
		

func no_control(collider):
	if collider in ally_control:
		ally_control.remove(ally_control.find(collider))
	elif collider in enemy_control:
		enemy_control.remove(enemy_control.find(collider))
	elif collider in buildings:
		buildings.remove(buildings.find(collider))
	elif collider in constructions:
		constructions.remove(constructions.find(collider))
		
func control(collider):
	if collider.get_name() == "TileMap":
		pass
	elif collider.has_method("positioning"):
		constructions.append(collider)
	elif collider.get_parent().faction.side == "allies" and collider.get_parent().has_method("attack"):
		ally_control.append(collider)
	elif collider.get_parent().faction.side == "enemies" and collider.get_parent().has_method("attack"):
		enemy_control.append(collider)
	elif collider.get_parent().has_method("initialize"):
		buildings.append(collider)

		
func set_controlled(fside):
	side = fside
	capturing = fside
	capture_time = capture_time_total
	get_node("Flagpole/" + str(fside) + "flag").set_opacity(1)
	get_node("Flagpole/" + str(fside) + "flag").set_pos(Vector2(0, -60))
	
func capturing(control, enemyflag):
	capturing = control
	get_node("Flagpole/" + str(enemyflag)+ "flag").set_opacity(0)
	get_node("Flagpole/" + str(control) + "flag").set_opacity(1)

func raise_flag(delta, control):
	capture_time += delta
	get_node("Flagpole/" + str(control) + "flag").set_pos(Vector2(0, 40.0 - (capture_time) * 10.0))
	if capture_time >= capture_time_total:
		if control != side:
			if constructions != []:
				for con in constructions:
					con.destroy()
			if ally_control != []:
				ally_control.front().get_parent().faction.player_list[0].construct_outpost(self)
		
			elif enemy_control != []:
				enemy_control.front().get_parent().faction.player_list[0].construct_outpost(self)
			level.check_win()
			side = control
		capture_time = capture_time_total
		
func lower_flag(delta, control, enemyflag):
	capture_time -= delta
	get_node("Flagpole/" + str(enemyflag) + "flag").set_pos(Vector2(0, 40.0 - (capture_time) * 10.0))
	if capture_time <= 0:
		capture_time = 0
		if buildings == []:
			capturing(control, enemyflag)
			side = ""


func red():
	red = true
	get_node("Area2D/Sprite").play("red")
	get_node("Area2D/Sprite").set_self_opacity(.5)
func green():
	red = false
	get_node("Area2D/Sprite").play("green")
	get_node("Area2D/Sprite").set_self_opacity(.5)



func points(delta):
	get_node("Flagpole/Label").set_text("Points in: " + "%01.f" % point_time)
	point_time -= delta
	if point_time <= 0:
		point_time = total_point_time
		level.points(side, points)
		
func _fixed_process(delta):
	if side != "":
		points(delta)
		
	if (ally_control.size() > 0 and enemy_control.size() < 1) or (enemy_control.size() > 0 and ally_control.size() < 1):
		var control
		var enemyflag
		if ally_control.size() > 0 and enemy_control.size() < 1:
			control = "allies"
			enemyflag = "enemies"
		elif enemy_control.size() > 0 and ally_control.size() < 1:
			control = "enemies"
			enemyflag = "allies"
			
		if side == control and capture_time < capture_time_total:
			raise_flag(delta, control)
		elif side == control:
			pass
		elif side == "" and capturing != control:
			lower_flag(delta, control, enemyflag)
		elif capturing == control and buildings == []:
			raise_flag(delta, control)
			get_node("Flagpole/Label").set_text(side + " Capturing: " + "%.2f" % capture_time)
		elif capturing != control or side != control:
			lower_flag(delta, control, enemyflag)
	
	if red == true: 
		opacity -= delta
		get_node("Area2D/Sprite").set_self_opacity(opacity)
		if opacity <= 0:
			opacity = .5
			red = false


