extends CharacterBody2D


const VEL = 50.0
const FRIC = 200.0
const RECOIL = -100.0
const JUMP_VEL = -360.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# RNG
var rng = RandomNumberGenerator.new()
var time_count = 0 

var idle_timer = 0
var idle_state = 0  # 0 = not moving, 1 = moving

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var ray_cast_floor = $RayCastFloor
@onready var ray_cast_wall = $RayCastWall

var isAttacking = false
var direction = -1

func _physics_process(delta):
	apply_graivity(delta)
	
	#if Input.is_action_just_pressed("dash"):
		#attack()
	idle_movement()
	avoid_edge()
	handle_movement(delta, direction)
	update_animations(direction)
	move_and_slide()  # ** automatically applies "delta"
	

func apply_graivity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func idle_movement():
	idle_timer -= 1
	print(idle_timer)
	if idle_timer <= 0:
		idle_state = (idle_state+1)%2
		idle_timer = int(60 * rng.randf_range(3, 7)) if idle_state == 1 else int(60*rng.randf_range(1, 3))
		if idle_state == 0:
			direction = 0
		else:
			set_direction(-1) if rng.randf() < 0.5 else set_direction(1)

func set_direction(d):
	if d == direction: return
	direction = d
	if ray_cast_wall.position.x < 0 and direction > 0 or ray_cast_wall.position.x > 0 and direction < 0:
		ray_cast_wall.position.x *= -1
		ray_cast_wall.scale.x *= -1
		ray_cast_floor.position.x *= -1
		
func avoid_edge():
	if not ray_cast_floor.is_colliding() or ray_cast_wall.is_colliding():
		flip_direction()
		
func flip_direction():
	direction *= -1
	ray_cast_wall.position.x *= -1
	ray_cast_wall.scale.x *= -1
	ray_cast_floor.position.x *= -1

func handle_movement(delta, direction):
	if isAttacking:
		velocity.x = move_toward(velocity.x, 0, FRIC*delta)
	else:
		if direction:
			velocity.x = VEL*direction
		else:
			velocity.x = move_toward(velocity.x, 0, VEL)
	
func attack():
	if isAttacking: return
	isAttacking = true
	var d = velocity.x / abs(velocity.x)
	velocity.x = RECOIL*d
	animation_player.play("attack")
	await animation_player.animation_finished
	animation_player.stop()
	isAttacking = false
	
func update_animations(direction):
	if isAttacking: return
	if direction == 0:
		animation_player.play("idle")
	else:
		sprite.flip_h = (direction > 0)
		animation_player.play("walk")
		
