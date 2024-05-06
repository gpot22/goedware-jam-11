extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var begin_gravity = false

func _ready():
	pass

func drop():
	#for j in range(4):
		#global_position = Vector2(global_position.x - 1, global_position.y)
		#await get_tree().create_timer(0.01).timeout
		#global_position = Vector2(global_position.x + 1, global_position.y)
		#await get_tree().create_timer(0.01).timeout
		#global_position = Vector2(global_position.x + 1, global_position.y)
		#await get_tree().create_timer(0.01).timeout
		#global_position = Vector2(global_position.x - 1, global_position.y)
		#await get_tree().create_timer(0.01).timeout
	begin_gravity = true

func _physics_process(delta):
	if begin_gravity:
		velocity.y += gravity * delta

	move_and_slide()
