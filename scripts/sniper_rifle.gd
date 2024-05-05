extends 'res://scripts/WeaponSuperclass.gd'

@onready var line_of_sight = $WeaponPivot/AnimatedSprite2D/BulletSpawn/LineOfSight
var can_shoot = true
var first_shot = true
var hide_line = false
var first_shot_damage

var current_magazine
var reloading = false

func _ready():
	super._ready()
	bullet = preload('res://scene/phase2/bullets/sniper_bullet.tscn')
	parent = get_parent().get_parent()
	
	first_shot_damage = 100
	damage = 49
	magazine = 5
	current_magazine = magazine
	direction = 1
	shot_time = 1.2
	bullet_spread = 0
	line_of_sight.visible = not is_player()
	first_shot = is_player()

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
	b.global_rotation = bullet_spawn.global_rotation
	add_child(b)
	if first_shot:
		first_shot = false
		b.first_shot = true
	can_shoot = false
	anim_sprite.play('shoot')
	hide_line = line_of_sight.visible
	line_of_sight.visible = false
	await get_tree().create_timer(0.4).timeout
	if hide_line:
		line_of_sight.visible = true
		hide_line = false
	await get_tree().create_timer(shot_time-0.4).timeout
	can_shoot = true

func toggle_line_color():
	if line_of_sight.default_color == Color('#ff463c78'):
		line_of_sight.default_color = Color('#ff463c40')
	else:
		line_of_sight.default_color = Color('#ff463c78')
		

func update_line_of_sight(target):
	var v = target.global_position - bullet_spawn.global_position
	line_of_sight.points = PackedVector2Array(
		[Vector2(0, 0), v]
	)

func reload():
	reloading = true
	await get_tree().create_timer(reload_time).timeout
	current_magazine = magazine
	can_shoot = true
	reloading = false
