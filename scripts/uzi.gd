extends 'res://scripts/WeaponSuperclass.gd'

var shoot_held = false
var shoot_timer = 0
var can_shoot = true
var reloading = false
var current_magazine

func _ready():
	super._ready()
	bullet = preload('res://scene/phase2/bullets/uzi_bullet.tscn')
	parent = get_parent().get_parent()
	direction = 1
	
	damage = 3
	magazine = 20
	current_magazine = magazine
	bullet_spread = 0.4
	shot_time = 0
	reload_time = 2
	
	
func _physics_process(delta):
	if is_player():
		point_to_cursor()
		handle_shoot()
		if shoot_held:
			if shoot_timer % 5 == 0 and current_magazine > 0 and can_shoot:

				shoot_timer = 0
				current_magazine -= 1
				shoot()
				parent.shoot_success()
			shoot_timer += 1
			if current_magazine == 0 and not reloading:
				can_shoot = false
				reload()
				

func point_to_cursor():
	var mouse = get_global_mouse_position()
	point_to_target(mouse)
	if mouse.x < global_position.x:
		scale.y = -1
	else:
		scale.y = 1
		
func handle_shoot():
	if active and Input.is_action_just_pressed('shoot'):
		shoot_held = true
		
	if active and Input.is_action_just_released('shoot'):
		shoot_held = false
		anim_sprite.play('stop_shoot')
		
func shoot():
	var b = bullet.instantiate()
	b.global_position = bullet_spawn.global_position
	b.global_rotation = bullet_spawn.global_rotation + rng.randf_range(-bullet_spread, bullet_spread)
	add_child(b)
	anim_sprite.play('shoot')
	

func reload():
	reloading = true
	anim_sprite.play('idle')
	await get_tree().create_timer(reload_time).timeout
	current_magazine = magazine
	can_shoot = true
	reloading = false
	
