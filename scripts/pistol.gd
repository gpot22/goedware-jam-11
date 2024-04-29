extends Node2D


const BULLET = preload('res://scene/phase2/player/bullet.tscn')
@onready var bullet_spawn = $WeaponPivot/PistolSprite/BulletSpawn
@onready var player = get_parent()
@onready var ap = $AnimationPlayer

var canShoot = true
var active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	point_to_cursor()
	handle_shoot()
	
	
func point_to_cursor():
	var mouse = get_global_mouse_position()
	look_at(mouse)
	bullet_spawn.look_at(mouse)
	if mouse.x < global_position.x:
		scale.y = -1
	else:
		scale.y = 1

func handle_shoot():
	if active and canShoot and Input.is_action_just_pressed('shoot'):
		shoot()
		
func shoot():
	var bullet = BULLET.instantiate()
	bullet.global_position = bullet_spawn.global_position
	bullet.global_rotation = bullet_spawn.global_rotation
	bullet_spawn.add_child(bullet)
	
	canShoot = false
	ap.play('shoot')
	await ap.animation_finished
	ap.stop()
	canShoot = true
	
func toggle_active(a):
	set_visible(a)
	active = a
