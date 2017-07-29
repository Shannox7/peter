extends Node2D
var name = "Flak Jacket"
var named = "Flak Jacket"
var value = 10
var armour = 1
var health = 10
var knockback_resist
var ammo_increase
var speed
var jump_height
var is_equipped = false
var stats
var GRAVITY = 100
var velocity
var random
var flipped = false

var pickup_area
var pickup = false
var player
func _ready():
	stats = [health, armour]
	get_node("Pickup/pick me up!").hide()
func equip(player):
	player.total_health += health
	player.armour += armour
func unequip(player):
	name = named
	player.total_health -= health
	player.armour -= armour
func equip_display(part, location):
	part.get_parent().remove_child(part)
	add_child(part)
	part.set_global_pos(get_node(location).get_global_pos())

func unlock():
	set_fixed_process(true)
	set_process_input(true)
	random = rand_range(-.05, .05)
	pickup = false
	pickup_area = get_node("Pickup")
	pickup_area.show()
	pickup_area.connect("body_enter", self, "pickmeup")
	pickup_area.connect("body_exit", self, "cantpickmeup")
	
func lock():
	set_fixed_process(false)
	set_process_input(false)
	get_node("CollisionShape2D").set_trigger(true)
	get_node("Pickup").hide()
	pickup_area.disconnect("body_enter", self, "pickmeup")
	pickup_area.disconnect("body_exit", self, "cantpickmeup")
	pickup = false
#	print('we locked')
	
func pickmeup(collider):
	if collider.is_in_group("players"):
		pickup = true
		get_node("Pickup/pick me up!").show()
		player = collider
		
func cantpickmeup(collider):
	if collider.get_name() != "TileMap" or collider.get_name() != "TileMap 2":
		pickup = false
		get_node("Pickup/pick me up!").hide()
	
	
func _fixed_process(delta):
	velocity = Vector2()
	velocity.y += delta * GRAVITY
	get_node("CollisionShape2D").set_trigger(false)
		
	if is_colliding():
		pass
	else:
		random = rand_range(-.05, .05)
		rotate(random)
	move(velocity)


	
func _input(event):
	if event.is_action_pressed("equip") and pickup == true:
		lock()
		self.get_parent().remove_child(self)
		player.equip(self, true, "armour")
	elif event.is_action_pressed("pickup") and pickup == true:
		lock()
		self.get_parent().remove_child(self)
		player.pack.append(self)
#		print(player.pack)
