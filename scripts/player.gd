extends CharacterBody2D

# PLAYER MOVEMENT VARIABLES
const VEL = 230.0
const ACC = 1600.0
const FRIC = 2000.0
const JUMP_VEL = -360.0
const DASH_VEL = 600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# PLAYER CHILD NODES
@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var collider = $CollisionShape2D

# PLAYER-RELATED OBJECTS
var bulletScene = preload('res://scene/bullet.tscn')
var camera = null

# PLAYER STATE MANAGERS
var direction = 1  # -1 = left, 1 = right
var jumpUp = false
var states = {
	"dash": false,
	"jump_start": false,
	"fall_start": false,
	"grapple": false
}

# PLAYER LOOP
func _physics_process(delta):
	apply_graivity(delta)
	
	# update input_axis and direction
	# - input axis: control player movement
	# - direction: for sprite's facing direction
	var input_axis = handle_input()
	
	# handle player movement, mechnanics and states
	handle_movement(delta, input_axis)
	handle_jump()
	handle_dash()
	handle_grapple()
	
	# update player anims and collider
	update_animations(input_axis)
	update_direction(input_axis)
	# apply velocity
	move_and_slide()
	
	if has_node("pistol"):
		if states['dash']:
			$pistol.toggle_active(false)
		else:
			$pistol.toggle_active(true)

# USER INPUT
func handle_input():
	var input_axis = Input.get_axis("left", "right")
	#if input_axis != 0:
		#direction = input_axis
	return input_axis

# PLAYER GRAVITY
func apply_graivity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

# - - - - PLAYER MOVEMENT FUNCTIONS - - - - 
func handle_movement(delta, input_axis):
	if input_axis:
		velocity.x = move_toward(velocity.x, VEL*direction, ACC*delta)  # player acceleration
	else:
		velocity.x = move_toward(velocity.x, 0, FRIC*delta)  # player friction
	
func handle_jump():
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			jumpUp = true
			velocity.y = JUMP_VEL
			animate_once('jump_start')
	else:
		if velocity.y > 0 and jumpUp:
			jumpUp = false
			animate_once('fall_start')
		if Input.is_action_just_released("jump") and velocity.y < JUMP_VEL/3:
			velocity.y = JUMP_VEL / 3

func handle_dash():
	if !Input.is_action_just_pressed("dash"): return
	velocity.x += DASH_VEL*direction
	ap.play('dash')
	states['dash'] = true
	await ap.animation_finished
	states['dash'] = false

func handle_grapple():
	if !Input.is_action_just_pressed('grapple'): return
	animate_once('grapple')

func animate_once(anim_name):
	ap.play(anim_name)
	states[anim_name] = true
	await ap.animation_finished
	states[anim_name] = false
	
# PLAYER ANIMATIONS
func update_animations(input_axis):
	sprite.flip_h = direction < 0
	if states.values().has(true): return
	# if no special state, do one of the following animations
	if input_axis != 0:
		if not is_on_floor():
			if velocity.y < 0:
				ap.play("jump_idle")
			else:
				ap.play("fall_idle")
		else:
			ap.play("run")
	elif is_on_floor():
		ap.play("idle")
		
# PLAYER COLLIDER
func update_direction(input_axis):
	if input_axis != 0:
		direction = input_axis
	update_collider(input_axis)
	#if (collider.position.x < 0 and direction > 0) or (collider.position.x > 0 and direction < 0):
		#return
	#collider.position.x *= -1
		

func update_collider(input_axis):
	var m = 1 if direction >= 0 else -1
	if input_axis != 0 and is_on_floor():  # running
		var shape: CapsuleShape2D = CapsuleShape2D.new()
		shape.radius = 20
		shape.height = 56
		collider.shape = shape
		collider.position = Vector2(-2*m, -10)
		collider.rotation_degrees = 90
	else:
		var shape: CapsuleShape2D = CapsuleShape2D.new()
		shape.radius = 16
		shape.height = 56
		collider.shape = shape
		collider.position = Vector2(-10*m, -14)
		collider.rotation_degrees = 0
	if has_node("pistol"):
		$pistol.position.x = abs($pistol.position.x) * -m
		
