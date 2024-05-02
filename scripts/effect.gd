extends AnimatedSprite2D

var state: String
# Called when the node enters the scene tree for the first time.
func _ready():
	play(state)
	await animation_finished
	queue_free()
