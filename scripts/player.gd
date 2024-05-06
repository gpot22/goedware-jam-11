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
@onready var smoke_spawn = $SmokeSpawn
@onready var world_map = $"../WorldMap"
@onready var coyote_timer = $CoyoteTimer
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var hook = $"../hook"
@onready var rope = $rope

const GRENADE_LAUNCHER = preload("res://scene/phase2/weapons/grenade_launcher.tscn")
const PISTOL = preload("res://scene/phase2/weapons/pistol.tscn")
const SHOTGUN = preload("res://scene/phase2/weapons/shotgun.tscn")
const SNIPER_RIFLE = preload("res://scene/phase2/weapons/sniper_rifle.tscn")
const UZI = preload("res://scene/phase2/weapons/uzi.tscn")

var sniper
var primary_weapon

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
var max_health = 160.0
var items = []

var animate_crosshair = false
var xhair_frames = 0
var xhair

var rng

func _ready():
	rng = RandomNumberGenerator.new()
	
	if 'sniper' in GlobalVariables.equipped_weapons:
		sniper = SNIPER_RIFLE.instantiate()
	if 'pistol' in GlobalVariables.equipped_weapons:
		primary_weapon = PISTOL.instantiate()
	elif 'uzi' in GlobalVariables.equipped_weapons:
		primary_weapon = UZI.instantiate()
	elif 'grenadelauncher' in GlobalVariables.equipped_weapons:
		primary_weapon = GRENADE_LAUNCHER.instantiate()
	get_node('WeaponPoint').add_child(primary_weapon)
	
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
	health = max_health
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
	if health <= 0:
		return
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
	handle_primary_weapon_swap()
	
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

func handle_primary_weapon_swap():
	if 'sniper' not in GlobalVariables.equipped_weapons:
		return
	if Input.is_action_just_pressed('swapprimary'):
		if get_node('WeaponPoint').get_child(0) == primary_weapon:
			get_node('WeaponPoint').remove_child(primary_weapon)
			get_node('WeaponPoint').add_child(sniper)
			Audio.play_sfx('sniper_equip')
		else:
			get_node('WeaponPoint').remove_child(sniper)
			get_node('WeaponPoint').add_child(primary_weapon)
			if 'pistol' in GlobalVariables.equipped_weapons:
				Audio.play_sfx('pistol_equip')
			elif 'uzi' in GlobalVariables.equipped_weapons:
				Audio.play_sfx('uzi_equip')

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
		#Audio.play_sfx('footsteps')
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
			Audio.play_sfx('jump')
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
	Audio.play_sfx('dash')
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
	$Sprite2D.self_modulate = Color('#aa0000')
	await get_tree().create_timer(0.2).timeout
	$Sprite2D.self_modulate = Color('#ffffff')
	Audio.play_sfx('hit' + str(rng.randi_range(1,3)))
	

func shotgun_recoil():
	var mouse = get_global_mouse_position()
	var v = mouse - global_position
	v = v/v.length()
	velocity = v * -SHOTTY_RECOIL

func die():
	health = 0
	$deathsprites.visible = true
	sprite.visible = false
	$WeaponPoint.visible = false
	$ShotgunPoint.visible = false
	ap.play('death')

func celebrate():
	$celebratesprites.visible = true
	sprite.visible = false
	$WeaponPoint.visible = false
	$ShotgunPoint.visible = false
	ap.play('celebrate')

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
	
