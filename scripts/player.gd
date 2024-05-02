extends 'res://scripts/CharacterSuperclass.gd'

# PLAYER MOVEMENT VARIABLES
const VEL = 500.0
const ACC = 2400.0
const FRIC = 3000.0
const JUMP_VEL = -900.0
const DASH_VEL = 1200.0

# PLAYER CHILD NODES
@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var collider = $CollisionShape2D
#@onready var run_smokes = [$smoke0, $smoke1]
@onready var smoke_spawn = $SmokeSpawn
@onready var tile_map = $"../TileMap"
@onready var world_map = $"../World Map"

var smoke_effect = preload('res://scene/vfx/smoke.tscn')
var smokes

# PLAYER-RELATED OBJECTS
#var bulletScene = preload('res://scene/phase2/player/bullet.tscn')
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

var pistol = null
var pistol_ipos = null

var grappling = false
var grapple_to
var grapple_speed = 900
var grapple_vel = Vector2(0, 0)
var grapple_direction

func _ready():
	if has_node('pistol'):
		pistol = $pistol
		pistol_ipos = Vector2(abs(pistol.position.x), pistol.position.y)

# PLAYER LOOP
func _physics_process(delta):
	if !grappling:
		apply_gravity(delta)
	
	# update input_axis and direction
	# - input axis: control player movement
	# - direction: for sprite's facing direction
	var input_axis = handle_input()
	
	# handle player movement, mechnanics and states
	handle_movement(delta, input_axis)
	handle_jump()
	handle_dash(input_axis)
	handle_grapple(delta)
	update_animations(input_axis)
	update_direction(input_axis)
	# apply velocity
	move_and_slide()
	
	if pistol:
		if states['dash']:
			pistol.toggle_active(false)
		else:
			pistol.toggle_active(true)

# USER INPUT
func handle_input():
	var input_axis = Input.get_axis("left", "right")
	#if input_axis != 0:
		#direction = input_axis
	return input_axis

# PLAYER GRAVITY
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity*2 * delta

# - - - - PLAYER MOVEMENT FUNCTIONS - - - - 
func handle_movement(delta, input_axis):
	if grappling:return
	if input_axis:
		velocity.x = move_toward(velocity.x, VEL*input_axis, ACC*delta)  # player acceleration
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
		if Input.is_action_just_released("jump") and velocity.y < 0 and jumpUp and !grappling:
			velocity.y = move_toward(velocity.y, 0, 2000)
		#if Input.is_action_just_released("jump") and velocity.y < JUMP_VEL/3:
			#velocity.y = JUMP_VEL / 3

func handle_dash(input_axis):
	if !Input.is_action_just_pressed("dash") or states['dash']: return
	velocity.x = DASH_VEL*direction if not input_axis else DASH_VEL*input_axis
	ap.play('dash')
	states['dash'] = true
	await ap.animation_finished
	states['dash'] = false

# PLAYER ANIMATIONS
func animate_once(anim_name):
	ap.play(anim_name)
	states[anim_name] = true
	await ap.animation_finished
	states[anim_name] = false
	
func handle_grapple(delta):
	if Input.is_action_just_pressed('grapple'):
		var platforms = world_map.get_children()
		var mouse_pos = get_global_mouse_position()
		for i in platforms:
			if mouse_pos.x > i.global_position.x - i.get_child(0).shape.size.x and mouse_pos.x < i.global_position.x + i.get_child(0).shape.size.x:
				if mouse_pos.y > i.global_position.y - i.get_child(0).shape.size.y and mouse_pos.y < i.global_position.y + i.get_child(0).shape.size.y:
					grappling = true
					grapple_to = mouse_pos
					grapple_vel = Vector2(cos(get_angle_to(grapple_to)), sin(get_angle_to(grapple_to)))
					if grapple_to.x > global_position.x and grapple_to.y > global_position.y:
						grapple_direction = 'rightdown'
					elif grapple_to.x < global_position.x and grapple_to.y > global_position.y:
						grapple_direction = 'leftdown'
					elif grapple_to.x > global_position.x and grapple_to.y < global_position.y:
						grapple_direction = 'rightup'
					elif grapple_to.x < global_position.x and grapple_to.y < global_position.y:
						grapple_direction = 'leftup'
					animate_once('grapple')
					velocity = grapple_vel * grapple_speed
	
	if grappling:
		if grapple_direction == 'rightup':
			if global_position.x > grapple_to.x or global_position.y < grapple_to.y:
				grappling = false
				return
		elif grapple_direction == 'leftup':
			if global_position.x < grapple_to.x or global_position.y < grapple_to.y:
				grappling = false
				return
		elif grapple_direction == 'rightdown':
			if global_position.x > grapple_to.x or global_position.y > grapple_to.y:
				grappling = false
				return
		elif grapple_direction == 'leftdown':
			if global_position.x < grapple_to.x or global_position.y > grapple_to.y:
				grappling = false
				return
		
func update_animations(input_axis):
	sprite.flip_h = direction < 0
	sprite.position.x = abs(sprite.position.x) * direction
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
			if smokes and (len(smokes.get_children()) != 0 or is_instance_valid(smokes.get_children())): return
			smokes = smoke_effect.instantiate()
			smoke_spawn.position.x = abs(smoke_spawn.position.x) * -direction
			get_parent().add_child(smokes)
			smokes.global_position = smoke_spawn.global_position 
			for s in smokes.get_children():
				s.flip_h = direction < 0
				
			#for s in run_smokes:
				#s.flip_h = direction < 0
				#s.position.x = abs(s.position.x) * -direction
				#s.play()
	elif is_on_floor():
		ap.play("idle")
		
# PLAYER COLLIDER
func update_direction(input_axis):
	var mouse = get_global_mouse_position()
	if mouse.x < global_position.x:
		direction = -1
	else:
		direction = 1
	if input_axis != 0 and is_on_floor():
		direction = input_axis
	update_collider(input_axis)
	if pistol:
		var m = 1 if input_axis == 0 or not is_on_floor() else 4
		var n = 1 if is_on_floor() else 1.8
		pistol.position.x = pistol_ipos.x * m * direction
		pistol.position.y = pistol_ipos.y * n
		

func update_collider(input_axis):
	if input_axis != 0 and is_on_floor():  # running
		var shape: CapsuleShape2D = CapsuleShape2D.new()
		shape.radius = 18
		shape.height = 40
		collider.shape = shape
		collider.position = Vector2(25*direction, -18)
		collider.rotation_degrees = 90
	else:
		var shape: CapsuleShape2D = CapsuleShape2D.new()
		shape.radius = 13
		shape.height = 56
		collider.shape = shape
		collider.position = Vector2(0, -28)
		collider.rotation_degrees = 0
		
