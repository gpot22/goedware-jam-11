extends 'res://scripts/EnemySuperclass.gd'


const RUN_VEL = 800
const JUMP = -1100
const GRAV = 3000

@onready var ap = $AnimationPlayer
@onready var evasion_area = $EvasionArea
@onready var shooting_area = $ShootingArea
@onready var sprite = $Sprite2D
@onready var ray_cast_wall = $CollisionShape2D/RayCastWall
@onready var ray_cast_floor = $CollisionShape2D/RayCastFloor
@onready var rifle = $'WeaponPoint/SniperRifle'

var platforms = []
var jumping = false
var jump_buffer = 0
var aiming = false
var shooting = false
var hurting = false
var first_shot = false
var last_floor
var aim_timer = 0
var aim_time_max = 80
var start_evade = false

func _ready():
	health = 100
	vel = 0
	set_direction(-1)
	position.x -= 40
	state = 'idle'  ## idle, evade, hostile
	rifle.visible = false
	
func _physics_process(delta):
	apply_gravity(delta)
	if $CollisionShape2D/RayCastFloor/floor.get_collider() != null and $CollisionShape2D/RayCastFloor/floor.get_collider().name.contains('platform'):
		last_floor = $CollisionShape2D/RayCastFloor/floor.get_collider()
	if state == 'idle':
		pass
	elif state == 'evade':
		rifle.visible = false
		if not run_from_player():
			state = 'hostile'
	
	elif state == 'hostile':
		face_player()
		if not first_shot and not aiming and not shooting and not hurting:  # start aiming
			first_shot = true
			ap.play('slide_shoot')
			await ap.animation_finished
			#ap.stop()
			aiming = true
			aim_timer = aim_time_max
			rifle.visible = true
		
		if shooting:
			rifle.visible = true
			shooting = false
			ap.play('recoil')
			$Sprite2D.global_position.x
			rifle.shoot()
			await ap.animation_finished
			ap.play('shoot')
			if start_evade:
				start_evade = false
				rifle.visible = false
				state = 'evade'
				vel = RUN_VEL
				aiming = false
				shooting = false
				first_shot = false
			else:
				aiming = true
				aim_timer = aim_time_max
		
		if aiming:
			aim_timer -= 1
			if aim_timer > 30:
				aim_at_player()
				if start_evade:
					start_evade = false
					state = 'evade'
					vel = RUN_VEL
					rifle.visible = false
					aiming = false
					shooting = false
					first_shot = false
			
			if state != 'evade':
				if aim_timer <= 60 and aim_timer%5 == 0:
					rifle.toggle_line_color()
					
				if aim_timer == 0:
					aiming = false
					shooting = true
			
	if jumping:
		jump_buffer -= 1
		if jump_buffer <= 0 and is_on_floor():
			jumping = false
			
	if not jumping:
		handle_movement(delta)
		
	var flag = false
	#for body in shooting_area.get_overlapping_bodies():
		#if body.name == 'Player':
			#flag = true
			#
	#if not flag:
		#state = 'idle'
	update_animations()
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += GRAV * delta


func update_animations():
	rifle.line_of_sight.visible = state == 'hostile' and rifle.visible
	if first_shot or aiming or shooting or hurting: return
	if not is_on_floor():
		ap.play('jump')
	else:
		if vel != 0:
			ap.play('run')
		else:
			ap.play("idle")

func set_direction(d):
	if d == 1:
		$Sprite2D.flip_h = true
		if direction != d:
			position.x -= 40
	else:
		$Sprite2D.flip_h = false
		if direction != d:
			position.x += 40
	direction = d
	$CollisionShape2D/RayCastFloor/floor.position.x = abs($CollisionShape2D/RayCastFloor/floor.position.x)*d
	$CollisionShape2D.position.x = abs($CollisionShape2D.position.x)*d
	ray_cast_wall.position.x = abs(ray_cast_wall.position.x)*d
	ray_cast_wall.target_position.x = abs(ray_cast_wall.target_position.x)*d
	$ScanPlatformArea/CollisionShape2D.position.x = abs($ScanPlatformArea/CollisionShape2D.position.x)*d
	
func handle_movement(delta):
	if vel:
		velocity.x = vel*direction
	else:
		velocity.x = move_toward(velocity.x, 0, RUN_VEL)
		
## STATE: IDLE
func is_on_edge():
	return not $CollisionShape2D/RayCastFloor/floor.is_colliding()

func is_on_bottom_floor():
	return ray_cast_floor.is_colliding() and ray_cast_floor.get_collider().name.contains('floor')
## STATE: EVADE
func get_nearest_platform():
	var surrounding_platforms = platforms.duplicate()
	if len(platforms) != 0:
		if last_floor != null and surrounding_platforms.has(last_floor):
			surrounding_platforms.erase(last_floor)
		
	if len(surrounding_platforms) == 0: return -1
	if len(surrounding_platforms) == 1: return surrounding_platforms[0]

	var min_v = surrounding_platforms[0].global_position - global_position
	var cur_v
	var closest = surrounding_platforms[0]
	for p in surrounding_platforms.slice(1):
		cur_v = p.global_position - global_position
		if custom_is_smaller_vector(cur_v, min_v):  # if current smaller than last minimum, replace as new minimum
			min_v = cur_v
			closest = p
	return closest
	
		#custom_larget_vector()

func custom_is_smaller_vector(smaller: Vector2, bigger: Vector2):
	if weighted_magnitude(smaller) < weighted_magnitude(bigger):
		return true
	return false

func weighted_magnitude(v):
	var x_weight = 0.8
	var y_weight = 1
	return sqrt((v.x * x_weight)**2 + (v.y * y_weight)**2)
	
func run_from_player():
	
	set_direction(1) if player.global_position.x < global_position.x else set_direction(-1)
	if (is_on_edge() or is_on_bottom_floor()) and not jumping:
		jumping = true
		jump_buffer = 20
		var p = get_nearest_platform()
		if typeof(p) == 2 and p == -1:
			## TODO
			return false
		var v = get_jump_vi(global_position.x, global_position.y, p.global_position.x, p.global_position.y)
		if not v:
			## TODO
			return false
		velocity = v
	return true
func get_jump_vi(xi, yi, xf, yf):
	var dx = xf - xi
	var dy = yf - yi
	
	var vix
	if dx > 0:
		vix = 500
	else:
		vix = -500
	var t = dx/vix
	var ay = GRAV
	var viy = dy/t - 0.5*ay*t
	if dy < -100:
		viy *= 1.4
		vix *= 0.4
	elif dy < 0:
		viy *= 1.1
		vix *= 0.9
		
	else:
		viy *= 1.05
		vix *= 0.95
	var v = Vector2(vix, viy)
	return v

func take_damage(dmg):
	var last_vel = vel
	if not (shooting or aiming):
		vel = 0
		ap.play('hurt')
		hurting = true
		
		$Sprite2D.self_modulate = Color('#aa0000')
		await ap.animation_finished
		$Sprite2D.self_modulate = Color('#ffffff')
		hurting = false
		vel = last_vel
		ap.stop()
	else:
		$Sprite2D.self_modulate = Color('#aa0000')
		await get_tree().create_timer(0.2).timeout
		$Sprite2D.self_modulate = Color('#ffffff')
		
	health -= dmg
	if health <= 0:
		queue_free()
	

## STATE: HOSTILE
func aim_at_player():
	if player == null: return
	var player_center = Vector2(player.global_position.x, player.global_position.y - player.sprite.get_rect().size.y/2)
	rifle.point_to_target(player_center)
	#rifle.line_of_sight.points[1] = Vector2(300, 0)
	if player.global_position.x < rifle.global_position.x:
		rifle.scale.y = -1
	else:
		rifle.scale.y = 1
		
	var line: Vector2 = rifle.line_of_sight.points[1]
	line = (line / line.length()) * rifle.bullet_spawn.global_position.distance_to(player_center) * 1.1
	rifle.line_of_sight.points[1] = line
	
func face_player():
	if not player: return
	if player.global_position.x < global_position.x:
		set_direction(-1)
		$WeaponPoint.position = Vector2(-15, -20)
	else:
		set_direction(1)
		$WeaponPoint.position = Vector2(15, -20)
	ray_cast_floor.position.x = abs(ray_cast_floor.position.x) * -direction
	#rifle.direction = direction

func _on_evasion_area_body_entered(body):
	if body.name != 'Player': return
	player = body
	start_evade = true
	#state = 'evade'
	#vel = RUN_VEL

func _on_evasion_area_body_exited(body):
	if body.name != 'Player': return
	player = body
	await get_tree().create_timer(0.5).timeout
	var flag
	for x in shooting_area.get_overlapping_bodies():
		if x.name == 'Player':
			flag = true
			state = 'hostile'
			
	if not flag:
		state = 'idle'
	vel = 0


func _on_scan_platform_area_body_entered(body):
	if not body.name.contains('platform'): return
	platforms.append(body)


func _on_scan_platform_area_body_exited(body):
	if not body.name.contains('platform'): return
	platforms.erase(body)


func _on_shooting_area_body_entered(body):
	if body.name != 'Player': return	
	player = body
	state = 'hostile'


func _on_shooting_area_body_exited(body):
	if body.name != 'Player': return	
	player = body
	state = 'idle'
	rifle.visible = false
	first_shot = false
	aiming = false
	shooting = false
	aim_timer = 0
