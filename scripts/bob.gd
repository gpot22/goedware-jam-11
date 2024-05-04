extends 'res://scripts/EnemySuperclass.gd'



const VEL = 90.0
const FRIC = 200.0
const RECOIL = -180.0


var time_count = 0 

var idle_timer = 0
var idle_state = 0  # 0 = not moving, 1 = moving
var hostile_timer = 0
var attack_timer = 0
var attack_charge_time = 60

@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var ray_cast_floor = $RayCastFloor
@onready var ray_cast_wall = $RayCastWall
@onready var ray_cast_player_detect = $RayCastPlayerDetect
@onready var ray_cast_attack = $RayCastAttack

var isAttacking = false
var face_dir = -1

func _ready():
	health = 100
	state = 'idle'
	direction = -1
	vel = 0

func _physics_process(delta):
	apply_gravity(delta)
	
	#if Input.is_action_just_pressed("dash"):
		#attack()
	detect_player()
	attack_player()
	if state == 'idle':
		idle_movement()
		avoid_edge()
	elif state == 'hostile':
		hostile_timer -= 1
		if hostile_timer == 0:
			state = 'idle'
		if player.position.x < position.x:
			set_direction(-1)
		else:
			set_direction(1)
		
	elif state == 'attack':
		display_attack_timer()
		attack_timer -= 1
		if attack_timer == 0:
			attack()
			state = 'hostile'
	handle_movement(delta, direction)
	update_animations(direction)
	move_and_slide()  # ** automatically applies "delta"


func display_attack_timer():
	if attack_timer == attack_charge_time:
		print(2)
	if attack_timer == attack_charge_time/2:
		print(1)
	if attack_timer == 1:
		print(0)

func idle_movement():
	idle_timer -= 1
	if idle_timer <= 0:
		idle_state = (idle_state+1)%2
		idle_timer = int(60 * rng.randf_range(3, 7)) if idle_state == 1 else int(60*rng.randf_range(1, 3))
		if idle_state == 0:
			direction = 0
		else:
			set_direction(-1) if rng.randf() < 0.5 else set_direction(1)

func detect_player():
	if ray_cast_player_detect.is_colliding() and ray_cast_player_detect.get_collider().name == "Player" and state != "attack":
		state = "hostile"
		hostile_timer = 60 * 2
		player = ray_cast_player_detect.get_collider()

func attack_player():
	if ray_cast_attack.is_colliding() and ray_cast_attack.get_collider().name == "Player":
		if state != 'attack':
			attack_timer = attack_charge_time
			direction = 0
		state = "attack"
		player = ray_cast_player_detect.get_collider()
	elif state == "attack" and attack_timer >= attack_charge_time/2:
		state = 'hostile'
		
		
func avoid_edge():
	if not ray_cast_floor.is_colliding() or ray_cast_wall.is_colliding():
		flip_direction()
		
func flip_direction():
	direction *= -1
	face_dir *= -1
	ray_cast_wall.position.x *= -1
	ray_cast_wall.scale.x *= -1
	ray_cast_floor.position.x *= -1
	ray_cast_player_detect.scale.x *= -1
	ray_cast_attack.scale.x *= -1
	
func set_direction(d):
	if d == direction: return
	direction = d
	face_dir = d
	if ray_cast_wall.position.x < 0 and direction > 0 or ray_cast_wall.position.x > 0 and direction < 0:
		ray_cast_wall.position.x *= -1
		ray_cast_wall.scale.x *= -1
		ray_cast_floor.position.x *= -1
		ray_cast_player_detect.scale.x *= -1
		ray_cast_attack.scale.x *= -1

func handle_movement(delta, direction):
	if isAttacking:
		velocity.x = move_toward(velocity.x, 0, FRIC*delta)
	else:
		if direction:
			var m = 2 if state == 'hostile' else 1
			velocity.x = VEL*direction * m
		else:
			velocity.x = move_toward(velocity.x, 0, VEL)
	
func attack():
	if isAttacking: return
	isAttacking = true
	velocity.x = RECOIL*face_dir
	ap.play("attack")
	await ap.animation_finished
	ap.stop()
	isAttacking = false
	
func update_animations(direction):
	if isAttacking: return
	if direction == 0:
		ap.play("idle")
	else:
		sprite.flip_h = (direction > 0)
		ap.play("walk")
		
func take_damage(dmg):
	$Sprite2D.self_modulate = Color('#aa0000')
	await get_tree().create_timer(0.2).timeout
	health -= dmg
	if health <= 0:
		queue_free()
	$Sprite2D.self_modulate = Color('#ffffff')
		
