extends Control
@onready var transition = $transition


# Called when the node enters the scene tree for the first time.
func _ready():
	transition.play("default")
	Audio.play_music('settings')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
