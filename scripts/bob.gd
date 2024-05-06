extends 'res://scripts/EnemySuperclass.gd'

const WALK_VEL = 140.0
const RUN_VEL = 220.0
const FRIC = 1200.0
const RECOIL = -600.0

@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var ray_cast_floor = $RayCastFloor
@onready var ray_cast_wall = $RayCastWall
@onready var ray_cast_wall2 = $RayCastWall2
@onready var player_detect_area = $PlayerDetectArea
@onready var attack_area = $AttackArea
@onready var weapon_point = $WeaponPoint

var shotgun = preload('res://scene/phase2/weapons/shotgun.tscn')
var uzi = preload('res://scene/phase2/weapons/uzi.tscn')
#var pistol = preload('res://scene/phase2/weapons/pistol.tscn')
var weapons = [shotgun, uzi]
var gun

var idle_state = 0
var idle_timer = 0
var hostile_timer = 0
var attack_timer = 0
var attack_pending = false
var shoot_ready = false
var shooting = false
var attack_recoil = false
var to_idle = false
var recoil_v

func _ready():
	health = 100
	state = 'idle'
	set_direction(-1)
	vel = 0
	# give gun
	var rand_weapon = rng.randi_range(0, len(weapons)-1)
	var gun_obj = weapons[rand_weapon]
	gun = gun_obj.instantiate()
	weapon_point.add_child(gun)
	
	player = get_parent().get_parent().get_parent().get_node('Player')
	
func _physics_process(delta):
	apply_gravity(delta)
	if state == 'idle':
		idle_movement()
		avoid_edge()
	elif state == 'hostile':
		if to_idle:
			hostile_timer -= 1
			if hostile_timer == 0:
				state= 'idle'
		if state != 'idle':
			if not shooting:
				follow_player()
				for b in $AttackArea.get_overlapping_bodies():
					if b.name == 'Player':
						shoot_ready = true
						break
				#if $CollisionShape2D.co
			if shoot_ready and not shooting and not attack_pending:
				attack_pending = true
				attack_timer = 40
				vel = 0
			if attack_pending and not shooting:
				vel = 0
				attack_timer -= 1
				if attack_timer == 0:
					attack()
					attack_pending = false
					shooting = true
			elif not shooting:
				vel = RUN_VEL
	handle_movement(delta)
	update_animations()
	if not attack_recoil:
		move_and_slide()
	
## STATE: IDLE
func avoid_edge():
	if not ray_cast_floor.is_colliding() or ray_cast_wall.is_colliding() or ray_cast_wall2.is_colliding():
		flip_direction()
		
func idle_movement():
	idle_timer -= 1
	if idle_timer <= 0:
		idle_state = (idle_state+1)%2  # 0 = stay still, 1 = wandering
		idle_timer = int(50 * rng.randf_range(4, 8)) if idle_state == 1 else int(50*rng.randf_range(1, 3))
		
		if idle_state == 0:
			vel = 0
		else:
			set_direction(-1) if rng.randf() < 0.5 else set_direction(1)
			vel = WALK_VEL
		
func flip_direction():
	direction *= -1
	set_direction(direction)
	
func set_direction(d):
	direction = d
	sprite.flip_h = (direction > 0)
	ray_cast_wall.position.x = abs(ray_cast_wall.position.x)*d
	ray_cast_wall.scale.x = abs(ray_cast_wall.scale.x)*-d
	ray_cast_wall2.position.x = abs(ray_cast_wall2.position.x)*d
	ray_cast_wall2.scale.x = abs(ray_cast_wall2.scale.x)*-d
	ray_cast_floor.position.x = abs(ray_cast_floor.position.x)*d
	
	player_detect_area.position.x = abs(player_detect_area.position.x)*d
	attack_area.position.x = abs(attack_area.position.x)*d
	weapon_point.position.x = abs(weapon_point.position.x)*d
	if gun == null: return
	if direction == 1:
		gun.point_to_target(global_position + Vector2.RIGHT*30 + Vector2.UP*32)
		gun.scale.y = 1
	else:
		gun.point_to_target(global_position + Vector2.LEFT*30 + Vector2.UP*32)
		gun.scale.y = -1

## STATE: HOSTILE
func follow_player():
	vel = RUN_VEL
	if player.global_position.x < global_position.x:
		set_direction(-1)
	else:
		set_direction(1)

func attack():
	shoot_ready = false
	shooting = true
	shoot()
	attack_recoil = true
	recoil_v = RECOIL*direction
	ap.play('attack')
	
func shoot():
	var player_center = Vector2(player.global_position.x, player.global_position.y - player.sprite.get_rect().size.y/2)
	gun.point_to_target(player_center)
	if player.global_position.x < gun.global_position.x:
		gun.scale.y = -1
	else:
		gun.scale.y = 1
	if gun.name == 'Uzi':
		for i in range(8):
			gun.shoot()
			gun.anim_sprite.play('stop_shoot')
			await get_tree().create_timer(0.05).timeout
	elif gun.name == 'Shotgun':
		for i in range(2):
			gun.shoot()
			await get_tree().create_timer(0.2).timeout


## GENERAL STUFF
func handle_movement(delta):
	if attack_recoil:
		vel = 0
		position.x += recoil_v*delta
		recoil_v += FRIC*direction*delta
		if direction == -1 and recoil_v <= 0.0 or direction == 1 and recoil_v >= 0.0:
			attack_recoil = false
			shooting = false
	else:
		if vel:
			velocity.x = vel*direction
		else:
			velocity.x = move_toward(velocity.x, 0, RUN_VEL)

func update_animations():
	if attack_recoil: return
	if vel != 0:
		ap.play('walk')
	else:
		ap.play("idle")

func take_damage(dmg):
	$Sprite2D.self_modulate = Color('#aa0000')
	await get_tree().create_timer(0.2).timeout
	health -= dmg
	if health <= 0:
		queue_free()
	$Sprite2D.self_modulate = Color('#ffffff')

#func handle_player_detection():
	#if player_in_detect_area():
		#state = 'hostile'
	#else:
		#state = 'idle'
		
#func handle_attack_detection():
	#if player_in_attack_area():
		#shoot_ready = true
	#else:
		#shoot_ready = false
#
#func player_in_detect_area():
	#var bodies = player_detect_area.get_overlapping_bodies()
	#for b in bodies:
		#if b.name == "Player":
			#return true
	#return false
	#
#func player_in_attack_area():
	#var bodies = attack_area.get_overlapping_bodies()
	#for b in bodies:
		#if b.name == "Player":
			#return true
	#return false
	
func _on_player_detect_area_body_entered(body):
	if body.name != 'Player': return
	state = 'hostile'
	to_idle = false


func _on_player_detect_area_body_exited(body):
	if body.name != 'Player': return
	#await get_tree().create_timer(3.0).timeout
	hostile_timer = 80
	to_idle = true
	#state = 'idle'


func _on_attack_area_body_entered(body):
	if body.name != 'Player': return
	#await get_tree().create_timer(1.0).timeout	
	shoot_ready = true

func _on_attack_area_body_exited(body):
	if body.name != 'Player': return
	#await get_tree().create_timer(1.0).timeout
	shoot_ready = false
