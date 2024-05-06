extends 'res://scripts/WeaponSuperclass.gd'

var can_shoot = true
var reloading = false
var current_magazine

func _ready():
	super._ready()
	bullet = preload('res://scene/phase2/bullets/grenade.tscn')
	parent = get_parent().get_parent()
	direction = -1 if not is_player() else 1

	damage = 30
	magazine = 6
	current_magazine = magazine
	bullet_spread = 0.2
	shot_time = 0.35
	reload_time = 1.2
	
	
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
			var dir: Vector2 = bullet_spawn.global_position - $WeaponPivot.global_position
			dir /= dir.length()
			var mouse = get_global_mouse_position()
			var d: Vector2 = mouse - $WeaponPivot.global_position
			var v = dir * grenade_spd(d.length())
			shoot(v)
			parent.shoot_success()
		elif current_magazine == 0 and not reloading:
			can_shoot = false
			reload()

func grenade_spd(r):
	var attrs = [
		{"r": 90, "spd": 300},
		{"r": 140, "spd": 450},
		{"r": 190, "spd": 600},
		{"r": 340, "spd": 750}
	]
	
	for val in attrs:
		if r < val["r"]:
			return val["spd"]
	return attrs[-1]["spd"]
	
func shoot(vel=null, x_offset=0):
	var grenade = bullet.instantiate()
	get_parent().get_parent().get_parent().add_child(grenade)
	if is_player():
		grenade.from_player = true
	grenade.global_position = bullet_spawn.global_position

	set_global_rotation(vel.angle())
	if direction == -1:
		scale.y = -1
	else:
		scale.y = 1
	
	grenade.vel = vel
	
	Audio.play_sfx('grenadelauncher' + str(rng.randi_range(1,3)))
	anim_sprite.play('shoot')
	await anim_sprite.animation_finished
	anim_sprite.stop()
	
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
	
