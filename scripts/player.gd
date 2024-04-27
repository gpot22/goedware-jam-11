extends CharacterBody2D


const VEL = 230.0
const ACC = 1600.0
const FRIC = 2000.0
const JUMP_VEL = -360.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D

var jumpUp = false
var states = {
	"dash": false,
	"jump_start": false,
	"fall_start": false,
	"gapple": false
}


func _physics_process(delta):
	apply_graivity(delta)
	var direction = Input.get_axis("left", "right")  # if left, -1; if right, +1, else 0
	
	handle_jump()
	handle_movement(delta, direction)
	
	handle_dash()
	handle_grapple()
	update_animations(direction)
	move_and_slide()  # ** automatically applies "delta"

func apply_graivity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
func handle_jump():
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VEL  # no delta bc move_and_slide()
			animation_player.play("jump_start")
			jumpUp = true
			states["jump_start"] = true
			await animation_player.animation_finished
			states["jump_start"] = false
	else:
		if velocity.y > 0 and jumpUp:
			jumpUp = false
			animation_player.play("fall_start")
			states["fall_start"] = true
			await animation_player.animation_finished
			states["fall_start"] = false
		if Input.is_action_just_released("jump") and velocity.y < JUMP_VEL/3:
			velocity.y = JUMP_VEL / 3

func handle_movement(delta, direction):
	if direction:
		velocity.x = move_toward(velocity.x, VEL*direction, ACC*delta)  # player acceleration
	else:
		velocity.x = move_toward(velocity.x, 0, FRIC*delta)  # player friction

func handle_dash():
	if Input.is_action_just_pressed("dash"):
		animation_player.play("dash")
		states["dash"] = true
		await animation_player.animation_finished
		states["dash"] = false

func handle_grapple():
	if Input.is_action_just_pressed('grapple'):
		animation_player.play('grapple')
		states["grapple"] = true
		await animation_player.animation_finished
		states["grapple"] = false
		
func update_animations(direction):
	if states.values().has(true): return
	if direction != 0:
		sprite.flip_h = direction < 0
		if not is_on_floor():
			if velocity.y < 0:
				animation_player.play("jump_idle")
			else:
				animation_player.play("fall_idle")
		else:
			animation_player.play("run")
	elif is_on_floor():
		animation_player.play("idle")
		
