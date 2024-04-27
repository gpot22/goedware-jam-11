extends CharacterBody2D


const VEL = 230.0
const ACC = 1600.0
const FRIC = 2000.0
const JUMP_VEL = -360.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var bulletScene = preload('res://scene/bullet.tscn')

@onready var animated_sprite_2d = $AnimatedSprite2D

func _physics_process(delta):
	apply_graivity(delta)
	handle_jump()
	
	var direction = Input.get_axis("left", "right")  # if left, -1; if right, +1, else 0
	
	handle_movement(delta, direction)
	
	update_animations(direction)
	move_and_slide()  # ** automatically applies "delta"
	
	handle_shoot()

func apply_graivity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
func handle_jump():
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VEL  # no delta bc move_and_slide()
	else:
		if Input.is_action_just_released("jump") and velocity.y < JUMP_VEL/3:
			velocity.y = JUMP_VEL / 3

func handle_movement(delta, direction):
	if direction:
		velocity.x = move_toward(velocity.x, VEL*direction, ACC*delta)  # player acceleration
	else:
		velocity.x = move_toward(velocity.x, 0, FRIC*delta)  # player friction
	
func update_animations(direction):
	if direction == 0:
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.flip_h = (direction < 0)
		if not is_on_floor():
			animated_sprite_2d.play("jump")
		else:
			animated_sprite_2d.play("run")

func handle_shoot():
	if Input.is_action_just_pressed("shoot"):
		var bullet = bulletScene.instantiate()
		
		get_parent().add_child(bullet)
		bullet.position = Vector2(get_position().x+10, get_position().y-10)
		
