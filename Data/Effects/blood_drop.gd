extends RigidBody2D
var splatter = false
var time = 5
var opacity = 1 
var level
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	level = get_parent()
	set_fixed_process(true)
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _fixed_process(delta):
	if get_node("collision").is_colliding() and not splatter:
		var follow_pos = Vector2(get_global_pos().x, get_global_pos().y)
		var coords = level.get_node("TileMap").world_to_map(follow_pos)
		var revert = level.get_node("TileMap").map_to_world(coords)
		var tilesize = level.get_node("TileMap").get_cell_size()
#		get_node("blood")
		get_node("blood").set_global_pos(Vector2(get_global_pos().x, revert.y + (tilesize.y - 6)))
		get_node("blood").show()
		get_node("blood").set_z(51)
		get_node("Sprite").hide()
		set_mode(1)
		splatter = true
	if splatter:
		time -= delta
		if time <= 0:
			opacity -= delta
			get_node("blood").set_opacity(opacity)
			if opacity <= 0:
				call_deferred("queue_free")
				
		