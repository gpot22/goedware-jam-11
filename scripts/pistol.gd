extends 'res://scripts/WeaponSuperclass.gd'

var can_shoot = true

func _ready():
	super._ready()
	bullet = preload('res://scene/phase2/bullet.tscn')
	parent = get_parent()
	damage = 10
	direction = 1
	shot_time = 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_player():
		point_to_cursor()
		handle_shoot()
	
func point_to_cursor():
	var mouse = get_global_mouse_position()
	point_to_target(mouse)
	if mouse.x < global_position.x:
		scale.y = -1
	else:
		scale.y = 1

func handle_shoot():
	if active and can_shoot and Input.is_action_just_pressed('shoot'):
		shoot()
		
func shoot():
	var b = bullet.instantiate()
	b.global_position = bullet_spawn.global_position
	b.global_rotation = bullet_spawn.global_rotation
	add_child(b)
	
	can_shoot = false
	anim_sprite.play('shoot')
	#await anim_sprite.animation_finished
	#anim_sprite.stop()
	await get_tree().create_timer(shot_time).timeout
	can_shoot = true
	
func toggle_active(a):
	set_visible(a)
	active = a
