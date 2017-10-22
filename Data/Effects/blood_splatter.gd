extends Particles2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_fixed_process(true)
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _fixed_process(delta):
	if is_emitting() == false:
		queue_free()