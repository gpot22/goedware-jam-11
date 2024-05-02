extends 'res://scripts/EnemySuperclass.gd'


const WALK_VEL = 200
const RUN_VEL = 400
const TACKLE_JUMP = -600
const TACKLE_GRAVITY = 2000

var idle_state = 0
var idle_timer = 0
var hostile_timer = 0 
var shoot_timer = 0



@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var shooting_area = $ShootingArea
@onready var ray_cast_floor = $RayCastFloor
@onready var ray_cast_wall = $RayCastWall
@onready var bombardier_gun = $bombardier_gun

var tackling = false
var tackle_ready = false
var must_tackle = false
var too_close = false
var tackle_timer = 0

var showering = false

func _ready():
	health = 100
	vel = 0
	state = 'idle'
	direction = -1

func _physics_process(delta):
	apply_gravity(delta)
	
	
	if state == 'idle':
		idle_movement()
		avoid_edge()
		bombardier_gun.visible = false
		
	elif state == 'hostile':
		bombardier_gun.visible = true
		face_player()
		shoot_timer -= 1
		if shoot_timer <= 0:
			bombardier_gun.visible = true
			vel = 0
			shoot_timer = 180
			showering = true
			await grenade_shower()
			showering = false
	
	elif state == 'suicidal':
		bombardier_gun.visible = false
		if !tackle_player():
			run_towards_player()
			jump_off_edge()
		else:
			ap.play('tackle')
			move_and_slide()
			await get_tree().create_timer(0.8).timeout
			queue_free()
	handle_movement(delta)
	update_animations()
	move_and_slide()

# - - - - - GENERAL MOVEMENT - - - - - - 
	
func apply_gravity(delta):
	if not is_on_floor():
		var g = gravity if !tackling else TACKLE_GRAVITY
		velocity.y += g * delta
		
func handle_movement(delta):
	if tackling: return
	if vel:
		velocity.x = vel*direction
	else:
		velocity.x = move_toward(velocity.x, 0, RUN_VEL)

func face_player():
	if not player: return
	if player.global_position.x < global_position.x:
		direction = -1
		bombardier_gun.position = Vector2(16, -8)
	else:
		direction = 1
		bombardier_gun.position = Vector2(-16, -8)
	bombardier_gun.direction = direction
	
func flip_direction():
	direction *= -1
	ray_cast_wall.scale.x *= -1
	ray_cast_wall.position.x *= -1
	bombardier_gun.direction = direction

# - - - - GENERAL ANIMATION STATE HANDLER - - - - -
func update_animations():
	if tackling: return
	sprite.flip_h = (direction > 0)
	if sprite.flip_h:
		$CollisionShape2D.position.x = abs($CollisionShape2D.position.x) * -1
	else:
		$CollisionShape2D.position.x = abs($CollisionShape2D.position.x)
	if vel == 0:
		if state == 'idle':
			ap.play("idle")
		elif state == 'hostile':
			ap.play('attack')
	else:
		if state == 'idle':
			ap.play("walk")
		elif state == 'hostile':
			ap.play("run")
			
# - - - - - STATE: IDLE - - - - - - 
func idle_movement():
	idle_timer -= 1
	if idle_timer <= 0:
		idle_state = (idle_state+1)%2
		idle_timer = int(60 * rng.randf_range(3, 7)) if idle_state == 1 else int(60*rng.randf_range(1, 3))
		if idle_state == 0:
			vel = 0
		else:
			vel = WALK_VEL
			if rng.randf() < 0.5:
				flip_direction()

func avoid_edge():
	if not ray_cast_floor.is_colliding() or ray_cast_wall.is_colliding():
		flip_direction()
# - - - - - STATE: HOSTILE - - - - - - 
func grenade_shower(n=6):
	var cooldown = 20
	var x_offset
	for i in range(n):
		if state == 'suicidal': return
		x_offset = int(rng.randf_range(-3, 3)*14)
		await get_tree().create_timer(0.2).timeout
		shoot(x_offset)
		
func shoot(x_offset=0):
	ap.play("attack")
	bombardier_gun.shoot(x_offset)
	await ap.animation_finished
	ap.stop()
# - - - - - STATE: SUICIDAL - - - - - - 
# suicidal, phase 1
func run_towards_player():
	direction = -1 if player.global_position.x < global_position.x else 1
	if too_close:
		direction *= -1
	tackle_timer -= 1
	if not tackle_timer:
		tackle_ready = true
	
func get_tackle_vi(xi, yi, xf, yf):
	var dx = xf - xi
	var dy = yf - yi

	var viy = TACKLE_JUMP
	var ay = TACKLE_GRAVITY
	
	
	var t =( -viy + sqrt(viy**2 -4*(ay/2)*(-dy)))/(ay)
	
	var vix = dx/t
	if is_nan(vix):
		vix = 480 * dx/(abs(dx))
	vix = max(min(700, vix), -700)
	var v = Vector2(vix, viy)
	return v
	
# suicidal, phase 2
func tackle_player():
	if !tackle_ready: return false
	if tackling: return true
	
	tackling = true
	
	var v = get_tackle_vi(global_position.x, global_position.y, player.global_position.x, player.global_position.y)
	velocity = v
	#print(v)
	return true
	
func jump_off_edge():
	if not ray_cast_floor.is_colliding():
		vel = 0
		await get_tree().create_timer(0.7).timeout
		tackle_ready = true

# - - - - - - SIGNALS AS STATE MANAGERS - - - - - -
func _on_shooting_area_body_entered(body):
	if body.name != 'Player': return
	if tackling: return
	#if showering: return
	player = body
	bombardier_gun.target = body
	state = 'hostile'
	vel = 0
	shoot_timer = 0

func _on_shooting_area_body_exited(body):
	if body.name != 'Player': return
	if must_tackle: return	
	if tackling: return
	#if showering: return
	state = 'idle'
	
func _on_tackle_area_body_entered(body):
	if body.name != 'Player': return
	if must_tackle: return	
	if tackling: return
	#if showering: return
	player = body
	tackle_ready = false
	state = 'suicidal'
	vel = RUN_VEL
	tackle_timer = 50
	
	
func _on_tackle_area_body_exited(body):
	if body.name != 'Player': return
	if must_tackle: return
	if tackling: return
	#if showering: return
	state = 'hostile'
	tackle_ready = false
	vel = 0
	tackle_timer = 50
	
func _on_commit_tackle_area_body_entered(body):
	if body.name != 'Player': return
	if tackling: return
	#if showering: return
	too_close = true
	must_tackle = true
	vel = RUN_VEL*1.1

func _on_commit_tackle_area_body_exited(body):
	if body.name != 'Player': return
	if tackling: return
	#if showering: return
	await get_tree().create_timer(0.2).timeout
	vel = RUN_VEL
	too_close = false
