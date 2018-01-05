extends Node2D


###
#Colours:
var red = Color(.6, 0, 0)
var blue = Color(0, 0, .6)
var green = Color(0, .6, 0)
var yellow = Color(.7, .7, 0)
var orange = Color(.8, .3, 0)
var purple = Color(.4, 0, .4)
var pink = Color(.7, 0, .45)
var brown = Color(0.45, 0.15, 0)
var gray = Color(0.3,0.3,0.3)
var white = Color(1, 1, 1)
var black = Color(0.1,0.1,0.1)

#skin clours
var pale = Color(.9, .6, .6)
var caucasian = Color(9,.6,.6)
var asian  = Color(.9,.8,.6)
var indian = Color(.6,.4,.2)
var african = Color(.2,.1,0)

#zombie skins
var dead_green = Color(.1, .45, 0)
var dead_dark_green = Color(0.05, .2, 0)
var dead_purple = Color(.55, 0, 0.55)
var dead_gray = Color(.25, 0.25, 0.25)

var skin_colors = []
var dead_skin_colors = []
var colors = []
var loaded = false
func _ready():
	if loaded == false:
		loaded = true
		skin_colors = [pale, caucasian, asian, indian, african]
		dead_skin_colors = [dead_green, dead_dark_green, dead_purple, dead_gray]
		colors = [blue, red, green, yellow, orange, purple, brown, gray, black, white, pink]

	pass

func generate_character(humanoid, zombie):
	_ready()
	var dead_skin_colour = dead_skin_colors[round(rand_range(0, dead_skin_colors.size() -1))]
	var skin_colour = skin_colors[round(rand_range(0, skin_colors.size() -1))]
	var shirt_colour = colors[round(rand_range(0, colors.size() -1))]
	var pants_colour = colors[round(rand_range(0, colors.size() -1))]
	var eye_colour = colors[round(rand_range(0, colors.size() -2))]
	var hair_colour = colors[round(rand_range(0, colors.size() -1))]
	var shoe_colour = colors[round(rand_range(0, colors.size() -1))]
	
	var male = false
	var gender = round(rand_range(0,1))
	if gender == 0:
		male = true
	else:
		male = false
		
#### head
	var head = null
	if zombie:
		head = get_node("Zombies/heads").get_children()[round(rand_range(0, get_node("Zombies/heads").get_children().size()-1))]
		humanoid.get_node("body/head").add_child(get_node("Zombies/head_effects").get_children()[round(rand_range(0, get_node("Zombies/head_effects").get_children().size()-1))].duplicate())
		humanoid.get_node("body/upper_body").add_child(get_node("Zombies/body_effects").get_children()[round(rand_range(0, get_node("Zombies/body_effects").get_children().size()-1))].duplicate())
		humanoid.get_node("body/arm_r").add_child(get_node("Zombies/arm_effects").get_children()[round(rand_range(0, get_node("Zombies/arm_effects").get_children().size()-1))].duplicate())
#		humanoid.get_node("body/arm_l").add_child(get_node("Zombies/arm_effects").get_children()[round(rand_range(0, get_node("Zombies/arm_effects").get_children().size()-1))].duplicate())
		humanoid.get_node("body/lower_body/leg_r/Sprite").add_child(get_node("Zombies/leg_effects").get_children()[round(rand_range(0, get_node("Zombies/leg_effects").get_children().size()-1))].duplicate())
		humanoid.get_node("body/lower_body/leg_l/Sprite").add_child(get_node("Zombies/leg_effects").get_children()[round(rand_range(0, get_node("Zombies/leg_effects").get_children().size()-1))].duplicate())

		eye_colour = red
		skin_colour = dead_skin_colour
	else:
		head =  get_node("Survivors/heads").get_children()[round(rand_range(0, get_node("Survivors/heads").get_children().size()-1))]
	
	var top_hair = get_node("Survivors/hair/top_hair").get_children()[round(rand_range(0, get_node("Survivors/hair/top_hair").get_children().size()-1))]
	var main_hair =get_node("Survivors/hair/main_hair").get_children()[round(rand_range(0, get_node("Survivors/hair/main_hair").get_children().size()-1))]
	humanoid.get_node("body/head").set_texture(head.get_texture())
	humanoid.get_node("body/head/top_hair").set_texture(top_hair.get_texture())
	humanoid.get_node("body/head/main_hair").set_texture(main_hair.get_texture())
	humanoid.get_node("body/head/inside_eye").set_modulate(eye_colour)

	humanoid.get_node("body/head").set_modulate(skin_colour)
	humanoid.get_node("body/head/top_hair").set_modulate(hair_colour)
	humanoid.get_node("body/head/main_hair").set_modulate(hair_colour)
	
##### Body

	var shirt_type
	if not male:
		shirt_type = get_node("Survivors/torso_female").get_children()[round(rand_range(0,2))]
	else:
		shirt_type = get_node("Survivors/torso").get_children()[round(rand_range(0,2))]
	var body = shirt_type.get_children()[round(rand_range(0, shirt_type.get_children().size()- 1))]
	var upper_body = body.get_node("torso")
	var arm_r = body.get_node("arm_r")
	var arm_l= body.get_node("arm_l")
	var arm_l_bicep = body.get_node("arm_l/bicep")
	var arm_r_bicep = body.get_node("arm_r/bicep")
	var arm_l_forearm = body.get_node("arm_l/bicep/forearm")
	var arm_r_forearm = body.get_node("arm_r/bicep/forearm")
	var arm_r_hand = body.get_node("arm_r/bicep/forearm/hand")
	var arm_l_hand = body.get_node("arm_l/bicep/forearm/hand")
	
	humanoid.get_node("body/arm_r/bicep").set_texture(arm_r_bicep.get_texture())
	humanoid.get_node("body/arm_l/bicep").set_texture(arm_l_bicep.get_texture())
	humanoid.get_node("body/arm_r/bicep/forearm").set_texture(arm_r_forearm.get_texture())
	humanoid.get_node("body/arm_l/bicep/forearm").set_texture(arm_l_forearm.get_texture())
	humanoid.get_node("body/arm_r/bicep/forearm/hand").set_texture(arm_r_hand.get_texture())
	humanoid.get_node("body/arm_l/bicep/forearm/hand").set_texture(arm_l_hand.get_texture())
	humanoid.get_node("body/upper_body").set_texture(upper_body.get_texture())

	if shirt_type == get_node("Survivors/torso/none"):
		humanoid.get_node("body/arm_r/bicep").set_modulate(skin_colour)
		humanoid.get_node("body/arm_l/bicep").set_modulate(skin_colour)
	else:
		humanoid.get_node("body/arm_r/bicep").set_modulate(shirt_colour)
		humanoid.get_node("body/arm_l/bicep").set_modulate(shirt_colour)
	if shirt_type == get_node("Survivors/torso/none") or shirt_type == get_node("Survivors/torso/short"):
		humanoid.get_node("body/arm_r/bicep/forearm").set_modulate(skin_colour)
		humanoid.get_node("body/arm_l/bicep/forearm").set_modulate(skin_colour)
	else:
		humanoid.get_node("body/arm_r/bicep/forearm").set_modulate(shirt_colour)
		humanoid.get_node("body/arm_l/bicep/forearm").set_modulate(shirt_colour)
		
	humanoid.get_node("body/arm_r/bicep/forearm/hand").set_modulate(skin_colour)
	humanoid.get_node("body/arm_l/bicep/forearm/hand").set_modulate(skin_colour)
	humanoid.get_node("body/upper_body").set_modulate(shirt_colour)
	
#### legs
	var pant_type = get_node("Survivors/legs").get_children()[round(rand_range(0, get_node("Survivors/legs").get_children().size()-1))]
	var legs = pant_type.get_children()[round(rand_range(0, pant_type.get_children().size()- 1))]
#	
	
	
	var lower_body = legs.get_node("lower_body")
	var leg_l = legs.get_node("lower_body/leg_l")
	var leg_r = legs.get_node("lower_body/leg_r")
	var leg_r_shin = legs.get_node("lower_body/leg_r/Sprite")
	var leg_l_shin = legs.get_node("lower_body/leg_l/Sprite")
	var leg_r_shoe = legs.get_node("lower_body/leg_r/Sprite/shoe")
	var leg_l_shoe = legs.get_node("lower_body/leg_l/Sprite/shoe")
	
	humanoid.get_node("body/lower_body/leg_r").set_texture(leg_r.get_texture())
	humanoid.get_node("body/lower_body/leg_l").set_texture(leg_r.get_texture())
	humanoid.get_node("body/lower_body/leg_r/Sprite").set_texture(leg_r_shin.get_texture())
	humanoid.get_node("body/lower_body/leg_l/Sprite").set_texture(leg_r_shin.get_texture())
	humanoid.get_node("body/lower_body/leg_r/Sprite/shoe").set_texture(leg_r_shoe.get_texture())
	humanoid.get_node("body/lower_body/leg_l/Sprite/shoe").set_texture(leg_r_shoe.get_texture())
	humanoid.get_node("body/lower_body").set_texture(lower_body.get_texture())
	
	humanoid.get_node("body/lower_body/leg_r").set_modulate(pants_colour)
	humanoid.get_node("body/lower_body/leg_l").set_modulate(pants_colour)
	if pant_type == get_node("Survivors/legs/short"):
		humanoid.get_node("body/lower_body/leg_r/Sprite").set_modulate(skin_colour)
		humanoid.get_node("body/lower_body/leg_l/Sprite").set_modulate(skin_colour)
	else:
		humanoid.get_node("body/lower_body/leg_r/Sprite").set_modulate(pants_colour)
		humanoid.get_node("body/lower_body/leg_l/Sprite").set_modulate(pants_colour)
	humanoid.get_node("body/lower_body/leg_r/Sprite/shoe").set_modulate(shoe_colour)
	humanoid.get_node("body/lower_body/leg_l/Sprite/shoe").set_modulate(shoe_colour)
	
	humanoid.get_node("body/lower_body").set_modulate(pants_colour)


