extends 'res://scripts/CharacterSuperclass.gd'

# PLAYER MOVEMENT VARIABLES
const VEL = 500.0
const ACC = 2400.0
const FRIC = 3000.0
const JUMP_VEL = -900.0
const DASH_VEL = 1200.0
const SHOTTY_RECOIL = 800

# PLAYER CHILD NODES
@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var collider = $CollisionShape2D
#@onready var run_smokes = [$smoke0, $smoke1]
@onready var smoke_spawn = $SmokeSpawn
@onready var tile_map = $"../TileMap"
@onready var world_map = $"../WorldMap"
@onready var coyote_timer = $CoyoteTimer
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var hook = $"../hook"
@onready var rope = $rope


var smoke_effect = preload('res://scene/vfx/smoke.tscn')
var smokes

# PLAYER-RELATED OBJECTS
var camera: Camera2D

# PLAYER STATE MANAGERS
var direction = 1  # -1 = left, 1 = right
var jumpUp = false
var states = {
	"dash": false,
	"jump_start": false,
	"fall_start": false,
	"grapple": false
}

var gun = null
var gun_ipos = null

var shotgun = null
var shotgun_ipos = null

var shotgun_range = false

var grappling = false
var grapple_to
var grapple_speed = 900
var grapple_vel = Vector2(0, 0)
var grapple_direction

# PLAYER STATS
var health
var items = []

var animate_crosshair = false
var xhair_frames = 0
var xhair

func _ready():
	if $WeaponPoint.get_child_count() != 0:
		gun = $WeaponPoint.get_child(0)
		gun_ipos = Vector2(abs(gun.position.x), gun.position.y)
	if $ShotgunPoint.get_child_count() != 0:
		shotgun = $ShotgunPoint.get_child(0)
		shotgun_ipos = Vector2(abs(shotgun.position.x), shotgun.position.y)
		shotgun.toggle_active(false)
	
	camera = get_parent().get_node('Camera2D')
	if gun.name == 'SniperRifle':
		camera.zoom = Vector2(0.4, 0.4)
	else:
		camera.zoom = Vector2(0.55, 0.55)
	health = 500
	items = []
	
	xhair = get_parent().get_node('xhair')
	
func shoot_success():
	animate_crosshair = true
	
func _process(delta):
	if animate_crosshair:
		Input.set_custom_mouse_cursor(xhair.texture.get_frame_texture(xhair_frames), 0, Vector2(22, 22))
		xhair_frames += 1
		if xhair_frames >= 7:
			xhair_frames = 0
			Input.set_custom_mouse_cursor(xhair.texture.get_frame_texture(0), 0, Vector2(22, 22))
			animate_crosshair = false
	
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
	
	if gun and not shotgun_range:
		if states['dash']:
			gun.toggle_active(false)
		else:
			gun.toggle_active(true)
	if shotgun and shotgun_range:
		if states['dash']:
			shotgun.toggle_active(false)
		else:
			shotgun.toggle_active(true)
	
	var was_on_floor = is_on_floor()
	
	# apply velocity
	move_and_slide()
	
	if was_on_floor && !is_on_floor():
		coyote_timer.start()

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
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()
	if Input.is_action_just_released("jump"):
		$JumpReleaseBufferTimer.start()
	if is_on_floor() or !coyote_timer.is_stopped() and not jumpUp:
		if (Input.is_action_just_pressed("jump") or !jump_buffer_timer.is_stopped()):
			jumpUp = true
			velocity.y = JUMP_VEL
			animate_once('jump_start')
	else:
		if velocity.y > 0 and jumpUp:
			jumpUp = false
			animate_once('fall_start')
		if (Input.is_action_just_released("jump") or !$JumpReleaseBufferTimer.is_stopped()) and velocity.y < 0 and jumpUp and !grappling:
			velocity.y = move_toward(velocity.y, 0, 2000)

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
					hook.global_rotation = get_angle_to(grapple_to)
					hook.visible = true
					hook.global_position = grapple_to
					rope.get_child(0).points = PackedVector2Array([Vector2(0,0), grapple_to - rope.global_position])
					rope.visible = true
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
		rope.get_child(0).points = PackedVector2Array([Vector2(0,0), grapple_to - rope.global_position])
		if grapple_direction == 'rightup':
			if global_position.x > grapple_to.x or global_position.y < grapple_to.y:
				hook.visible = false
				rope.visible = false
				grappling = false
				return
		elif grapple_direction == 'leftup':
			if global_position.x < grapple_to.x or global_position.y < grapple_to.y:
				grappling = false
				hook.visible = false
				rope.visible = false
				return
		elif grapple_direction == 'rightdown':
			if global_position.x > grapple_to.x or global_position.y > grapple_to.y:
				grappling = false
				hook.visible = false
				rope.visible = false
				return
		elif grapple_direction == 'leftdown':
			if global_position.x < grapple_to.x or global_position.y > grapple_to.y:
				grappling = false
				hook.visible = false
				rope.visible = false
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
	if input_axis and is_on_floor():
		$WeaponPoint.position.y = -15
		$ShotgunPoint.position.y = -15
	else:
		$WeaponPoint.position.y = -25
		$ShotgunPoint.position.y = -25
	if mouse.x < global_position.x:
		direction = -1
		
		if input_axis == direction:
			$WeaponPoint.position.x = -50
			$ShotgunPoint.position.x = -50
		else:
			$WeaponPoint.position.x = -20
			$ShotgunPoint.position.x = -20
	else:
		if input_axis == direction:
			$WeaponPoint.position.x = 30
			$ShotgunPoint.position.x = 30
		else:
			$WeaponPoint.position.x = 20
			$ShotgunPoint.position.x = 20
		direction = 1
	if input_axis != 0 and is_on_floor():
		direction = input_axis
	update_collider(input_axis)
	if gun:
		var m = 1 if input_axis == 0 or not is_on_floor() else 4
		var n = 1 if is_on_floor() else 1.8
		gun.position.x = gun_ipos.x * m * direction
		gun.position.y = gun_ipos.y * n
	
	#if direction == 1:
		#rope.global_position = 
	rope.position.x = abs(rope.position.x) * direction

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
		
func take_damage(dmg):
	#print('player damaged: ', dmg)
	health -= dmg
	#print('ow', dmg)
	lose_level()
	
func lose_level():
	pass
	#print('ur shit')
	

func shotgun_recoil():
	var mouse = get_global_mouse_position()
	var x = 1 if mouse.x < global_position.x else -1
	velocity.x = SHOTTY_RECOIL * x

func _on_shotgun_area_body_entered(body):
	if not body.is_in_group('Enemy'): return
	if not shotgun: return
	# HAS SHOTGUN
	if not shotgun_range:
		shotgun.current_magazine = shotgun.magazine
	shotgun_range = true
	gun.toggle_active(false)
	shotgun.toggle_active(true)
	
func _on_shotgun_area_body_exited(body):
	if not body.is_in_group('Enemy'): return
	if not shotgun: return
	# HAS SHOTGUN
	shotgun_range = false
	gun.toggle_active(true)
	shotgun.toggle_active(false)
	
