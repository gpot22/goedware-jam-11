extends 'res://scripts/WeaponSuperclass.gd'

var can_shoot = true
var reloading = false
var current_magazine
var bullets_per_shell = 10

func _ready():
	super._ready()
	bullet = preload('res://scene/phase2/bullets/shotgun_bullet.tscn')
	parent = get_parent().get_parent()
	direction = 1
	
	damage = int(20 / bullets_per_shell)
	magazine = 2
	current_magazine = magazine
	bullet_spread = 0.6
	shot_time = 0.4
	reload_time = 1.6
	
	
func _physics_process(delta):
	if is_player() and active:
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
	if active and Input.is_action_just_pressed('shoot'):
		if current_magazine > 0 and can_shoot:
			current_magazine -= 1
			shoot()
			parent.shoot_success()
			parent.shotgun_recoil()
		elif current_magazine == 0 and not reloading:
			can_shoot = false
			reload()
		
func shoot():
	can_shoot = false
	var b
	for i in range(bullets_per_shell):
		b = bullet.instantiate()
		b.global_position = bullet_spawn.global_position
		if i%2 == 0:
			b.global_rotation = bullet_spawn.global_rotation + rng.randf_range(-bullet_spread, 0)
		else:
			b.global_rotation = bullet_spawn.global_rotation + rng.randf_range(0, bullet_spread)
		add_child(b)
	anim_sprite.play('shoot')
	await get_tree().create_timer(shot_time).timeout
	if current_magazine != 0:
		can_shoot = true
	

func reload():
	reloading = true
	await get_tree().create_timer(reload_time).timeout
	current_magazine = magazine
	can_shoot = true
	reloading = false
	
