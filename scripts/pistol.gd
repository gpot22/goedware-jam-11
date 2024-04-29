extends Node2D


const BULLET = preload("res://scene/bullet.tscn")
@onready var bullet_spawn = $WeaponPivot/PistolSprite/BulletSpawn
@onready var player = get_parent()
@onready var ap = $AnimationPlayer

var canShoot = true

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
	if canShoot and Input.is_action_just_pressed('shoot'):
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
	#print(int(get_rotation_degrees()) % 360)
	#if Input.is_action_just_pressed("shoot"):
		#var bullet = bulletScene.instantiate()
		#bullet.add_collision_exception_with(self)
		#bullet.add_collision_exception_with(get_parent())
		#get_parent().add_child(bullet)
		#bullet.position = Vector2(get_position().x, get_position().y-4)
		#if get_local_mouse_position().x < 0:
			#bullet.vel.x = -600*delta
		#else:
			#bullet.vel.x = 600*delta
	
	pass
