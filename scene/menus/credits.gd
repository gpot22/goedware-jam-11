extends Control
@onready var transition = $transition


# Called when the node enters the scene tree for the first time.
func _ready():
	transition.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
