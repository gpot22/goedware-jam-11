extends 'res://scripts/EnemySuperclass.gd'

const WALK_VEL = 200
const RUN_VEL = 400
const TACKLE_JUMP = -650
const TACKLE_GRAVITY = 2000

var idle_state = 0
var idle_timer = 0
var hostile_timer = 0 
var shoot_timer = 0

var grenade = preload('res://scene/phase2/bullets/grenade.gd')
var explosion_effect = preload('res://scene/vfx/explosion.tscn')

@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var shooting_area = $ShootingArea
@onready var ray_cast_floor = $RayCastFloor
@onready var ray_cast_wall = $RayCastWall
@onready var grenade_launcher = $WeaponPoint/grenade_launcher
@onready var explosion_radius = $ExplosionRadius
@onready var too_close = $TooClose
@onready var explode_timer = $ExplodeTimer


var tackling = false
var tackle_ready = false
var must_tackle = false
var tackle_timer = 150
var ready_to_explode = false

var showering = false

func _ready():
	health = 150
	vel = 0
	state = 'idle'
	direction = -1
	player = get_parent().get_parent().get_parent().get_node('Player')

var tackled = false
func _physics_process(delta):
	apply_gravity(delta)
	if state == 'idle':
		idle_movement()
		avoid_edge()
		grenade_launcher.visible = false
		
	elif state == 'hostile':
		grenade_launcher.visible = true
		vel = 0
		face_player()
		shoot_timer -= 1
		if shoot_timer <= 0:
			grenade_launcher.visible = true
			vel = 0
			shoot_timer = 180
			showering = true
			await grenade_shower()
			showering = false
	
	elif state == 'suicidal':
		grenade_launcher.visible = false
		if !tackle_player():  # not tackling yet
			if not is_too_close():
				vel = RUN_VEL
				run_towards_player()
			else:
				vel = 0
			if not tackle_ready:
				explode_timer.start()
				tackle_ready = true
			jump_off_edge()
		else:
			tackled = true
			ap.play('tackle')
			move_and_slide()
			#ready_to_explode = true
			#explode_timer.start()
			#var explosion = explosion_effect.instantiate()
			#get_parent().get_parent().add_child(explosion)
			#explosion.scale *= 1.2
			#explosion.global_position = global_position
			#explode_damage()
			#print('fuck you!')
			#queue_free()
	
	if tackled:
		if get_tree() == null:
			return
		await get_tree().create_timer(0.8).timeout
		var explosion = explosion_effect.instantiate()
		get_parent().get_parent().add_child(explosion)
		explosion.scale *= 1.2
		explosion.global_position = global_position
		explode_damage()
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
		$WeaponPoint.position = Vector2(16, -8)
	else:
		direction = 1
		$WeaponPoint.position = Vector2(-16, -8)
	ray_cast_floor.position.x = abs(ray_cast_floor.position.x) * -direction
	grenade_launcher.direction = direction
	
func flip_direction():
	direction *= -1
	position.x + direction * 20
	ray_cast_wall.scale.x *= -1
	ray_cast_wall.position.x *= -1
	ray_cast_floor.position.x *= -1
	grenade_launcher.direction = direction

func is_too_close():
	for b in too_close.get_overlapping_bodies():
		if b.name == 'Player':
			return true
			
	return false
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

func get_grenade_vi(xi, yi, xf, yf, g):
	var dx = xf - xi
	var dy = yf - yi
	var viy = -800
	var ay = g
	var t =( -viy + sqrt(viy**2 -4*(ay/2)*(-dy)))/(ay)
	var vix = dx/t
	return Vector2(vix, viy)

func shoot(x_offset=0):
	ap.play("attack")
	var xi = grenade_launcher.bullet_spawn.global_position.x
	var yi = grenade_launcher.bullet_spawn.global_position.y
	
	var xf = player.global_position.x + x_offset
	var yf = player.global_position.y
	var vel = get_grenade_vi(xi, yi, xf, yf, grenade.new().GRAVITY)
	grenade_launcher.shoot(vel, x_offset)
	await ap.animation_finished
	ap.stop()
	
func grenade_shower(n=4):
	grenade_launcher.visible = true
	var cooldown = 20
	var x_offset
	for i in range(n):
		if state == 'suicidal': return
		x_offset = int(rng.randf_range(-4, 4)*15)
		if get_tree() == null:
			return
		await get_tree().create_timer(0.2).timeout
		shoot(x_offset)
# - - - - - STATE: SUICIDAL - - - - - - 
# suicidal, phase 1
func run_towards_player():
	direction = -1 if player.global_position.x < global_position.x else 1
	
	
func get_tackle_vi(xi, yi, xf, yf):
	var dx = xf - xi
	var dy = yf - yi
	#if dy < -30:  # jump up
	var viy = TACKLE_JUMP
	var ay = TACKLE_GRAVITY
	
	
	var t =( -viy + sqrt(viy**2 -4*(ay/2)*(-dy)))/(ay)
	
	var vix = dx/t
	if is_nan(vix):
		viy *= 1.7
		t =( -viy + sqrt(viy**2 -4*(ay/2)*(-dy)))/(ay)
		vix = dx/t
	
	if is_nan(vix):
		vix = 480 * dx/(abs(dx))
	vix = max(min(700, vix), -700)
	var v = Vector2(vix, viy)
	return v
	
# suicidal, phase 2
func tackle_player():
	#if !tackle_ready: return false
	if tackling: return true
	
	if tackle_ready and explode_timer.is_stopped():
		tackling = true
		var v = get_tackle_vi(global_position.x, global_position.y, player.global_position.x, player.global_position.y)
		velocity = v
		return true
	return false

var on_edge = false
func jump_off_edge():
	if not is_on_floor() or on_edge:
		if not on_edge:
			position.x += 5*-direction
			on_edge = true
		vel = 0
		#explode_timer.start()
		#ready_to_expode = true
		tackle_ready = true

func explode_damage():
	if !explosion_radius.has_overlapping_bodies(): return
	for body in explosion_radius.get_overlapping_bodies():
		if body.name == 'Player':
			var v: Vector2 = body.global_position - explosion_radius.global_position
			var dmg = get_dmg(v.length())
			body.take_damage(dmg)
			
func get_dmg(r):
	var attrs = [
		{'r': 80, 'dmg': 70},
		{'r': 120, 'dmg': 40},
		{'r': 160, 'dmg': 30}
	]
	for val in attrs:
		if r < val["r"]:
			return val["dmg"]
	return attrs[-1]["dmg"]
# - - - - - - SIGNALS AS STATE MANAGERS - - - - - -
func _on_shooting_area_body_entered(body):
	if body.name != 'Player': return
	if tackling: return
	player = body
	grenade_launcher.target = body
	state = 'hostile'
	vel = 0
	shoot_timer = 0

func _on_shooting_area_body_exited(body):
	if body.name != 'Player': return
	if must_tackle: return	
	if tackling: return
	if tackled:return
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
	tackle_timer = 150
	
	
func _on_tackle_area_body_exited(body):
	if body.name != 'Player': return
	if tackled:return
	#if tackling: return
	#if showering: return
	state = 'hostile'
	tackle_ready = false
	explode_timer.stop()
	ready_to_explode = false
	vel = 0
	tackle_timer = 150
	
func _on_commit_tackle_area_body_entered(body):
	if body.name != 'Player': return
	if tackling: return
	#if showering: return
	#must_tackle = true
	vel = RUN_VEL*1.1

func take_damage(dmg):
	health -= dmg
	$Sprite2D.self_modulate = Color('#aa0000')
	if get_tree() == null:
		return
	await get_tree().create_timer(0.2).timeout
	if health <= 0:
		queue_free()
	$Sprite2D.self_modulate = Color('#ffffff')


func _on_leave_commit_tackle_body_exited(body):
	if body.name != 'Player': return
	if tackling: return
	#if showering: return
	#await get_tree().create_timer(0.2).timeout
	vel = RUN_VEL
