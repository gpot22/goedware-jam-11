extends 'res://scripts/WeaponSuperclass.gd'

var can_shoot = true
var reloading = false
var current_magazine

func _ready():
	super._ready()
	bullet = preload('res://scene/phase2/bullets/bullet.tscn')
	parent = get_parent().get_parent()
	direction = 1
	
	damage = 10
	magazine = 12
	current_magazine = magazine
	shot_time = 0.4
	bullet_spread = 0.05
	reload_time = 0.8

# Called every frame. 'delta' is the elapsed time since the previous frame.
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
	if active and can_shoot and Input.is_action_just_pressed('shoot'):
		if current_magazine > 0 and can_shoot:
			current_magazine -= 1
			shoot()
			parent.shoot_success()
		elif current_magazine == 0 and not reloading:
			can_shoot = false
			reload()
		
func shoot():
	var b = bullet.instantiate()
	b.global_position = bullet_spawn.global_position
	b.global_rotation = bullet_spawn.global_rotation + rng.randf_range(-bullet_spread, bullet_spread)
	add_child(b)
	
	can_shoot = false
	anim_sprite.play('shoot')
	#await anim_sprite.animation_finished
	#anim_sprite.stop()
	if get_tree() == null:
		can_shoot = true
		return
	await get_tree().create_timer(shot_time).timeout
	can_shoot = true

func shoot_at(target):
	bullet_spawn.look_at(target)
	shoot()
	
func toggle_active(a):
	set_visible(a)
	active = a

func reload():
	reloading = true
	if get_tree() == null:
		current_magazine = magazine
		can_shoot = true
		reloading = false
		return
	await get_tree().create_timer(reload_time).timeout
	current_magazine = magazine
	can_shoot = true
	reloading = false
