extends 'res://scripts/WeaponSuperclass.gd'

@onready var line_of_sight = $WeaponPivot/AnimatedSprite2D/BulletSpawn/LineOfSight
var can_shoot = true

func _ready():
	super._ready()
	bullet = preload('res://scene/phase2/bullets/sniper_bullet.tscn')
	parent = get_parent().get_parent()
	damage = 49
	direction = 1
	shot_time = 1.2
	bullet_spread = 0
	line_of_sight.visible = not is_player()

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
	if line_of_sight.visible:
		line_of_sight.width = 4
		line_of_sight.default_color = Color('#ff463cc8')
		
	await get_tree().create_timer(0.4).timeout
	if line_of_sight.visible:
		line_of_sight.width = 2
		line_of_sight.default_color = Color('#ff463c78')
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
