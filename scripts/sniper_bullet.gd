extends 'res://scene/phase2/bullet.gd'


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	vel = 3000
	range = 1000
	max_w = 140
	max_h = 1
	set_shape(max_w, max_h)
	light.scale.x *= 6
	light.scale.y *= 0.5
