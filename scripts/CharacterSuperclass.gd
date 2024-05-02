extends CharacterBody2D

# BASE CONSTANTS
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
