extends StaticBody2D

# ATTRIBUTES
var health = 360
var state = 'idle'
var player = null
var damage = 10

# STUFF
@onready var base = $body/base
@onready var head = $body/HeadAnchor/head
@onready var spark = $body/HeadAnchor/head/BulletSpawn/spark


@onready var bullet_spawn = $body/HeadAnchor/head/BulletSpawn
@onready var line_of_sight = $body/HeadAnchor/head/BulletSpawn/LineOfSight

var bullet = preload('res://scene/phase2/bullets/turret_bullet.tscn')
var rng = RandomNumberGenerator.new()

var charging = false
var shoot_ready = false
var charge = 0
var MAX_CHARGE = 4
var charge_ready = true
var aim_timer = 0
var aim_time_max = 40
var aim_ready = true

func _ready():
	player = get_parent().get_parent().get_parent().get_node('Player')

func _physics_process(delta):
	state = 'hostile'
	if not charging and not shoot_ready and charge_ready:
		charge_up()
	if state == 'hostile':
		if (not shoot_ready or aim_timer > 30) and aim_ready:
			aim_at_player()
		else:
			aim_at_player_staggered()
		if shoot_ready:
			aim_timer -= 1
			if aim_timer <= 40 and aim_timer % 5 == 0:
				toggle_line_color()
			if aim_timer == 0:
				charge = 0
				base.play('idle')
				shoot_ready = false
				charge_ready = false
				await burst_shoot()
				charge_ready = true
	#update_animations()
	
#func update_animations():
	#if state == 'idle':
		#head.play('idle')
		#line_of_sight.visible = false
	#else:
		#line_of_sight.visible = true
		
func aim_at_player():
	var player_center = Vector2(player.global_position.x, player.global_position.y - player.sprite.get_rect().size.y/2)
	$body/HeadAnchor.look_at(player_center)
	if player.global_position.x < global_position.x:
		head.scale.y = -1
		head.position.y = 14
	else:
		head.scale.y = 1
		head.position.y = -14
	# update line of sight
	var line: Vector2 = line_of_sight.points[1]
	line = (line / line.length()) * bullet_spawn.global_position.distance_to(player_center)*0.5
	line_of_sight.points[1] = line
	
func aim_at_player_staggered():
	var player_center = Vector2(player.global_position.x, player.global_position.y - player.sprite.get_rect().size.y/2)
	if get_tree() == null:
		return
	await get_tree().create_timer(0.3).timeout
	$body/HeadAnchor.look_at(player_center)
	if player.global_position.x < global_position.x:
		head.scale.y = -1
		head.position.y = 14
	else:
		head.scale.y = 1
		head.position.y = -14
	# update line of sight
	var line: Vector2 = line_of_sight.points[1]
	line = (line / line.length()) * bullet_spawn.global_position.distance_to(player_center)*0.5
	line_of_sight.points[1] = line
	
func burst_shoot(n=30):
	line_of_sight.visible = false
	aim_ready = false
	for i in range(n):
		shoot()
		if get_tree() == null:
			return
		await get_tree().create_timer(0.04).timeout
	aim_ready = true
	line_of_sight.visible = true
	#await get_tree().create_timer(1.2-0.4).timeout

func toggle_line_color():
	if line_of_sight.default_color == Color('#ff463c78'):
		line_of_sight.default_color = Color('#ff463c40')
	else:
		line_of_sight.default_color = Color('#ff463c78')
		
func shoot():
	line_of_sight.visible = false
	var b = bullet.instantiate()
	b.global_position = Vector2(bullet_spawn.global_position.x, bullet_spawn.global_position.y)
	b.global_rotation = bullet_spawn.global_rotation + rng.randf_range(-0.07, 0.07)
	add_child(b)
	head.play('shoot_faster')
	spark.play('flash' + str(rng.randi_range(1,3)))
	await head.animation_finished
	head.stop()
	#anim_sprite.play('shoot')
	
func charge_up():
	var t = 0.6
	charging = true
	if get_tree() == null:
		return
	await get_tree().create_timer(0.8).timeout
	#var idle_interrupt = false
	if charge < 4:
		for i in range(charge+1, MAX_CHARGE+1):
			charge += 1
			base.play('charge' + str(i))
			if get_tree() == null:
				return
			await get_tree().create_timer(t).timeout
			base.stop()
	#if idle_interrupt: return
	charging = false
	aim_timer = aim_time_max
	shoot_ready = true
	
func take_damage(dmg):
	head.self_modulate = Color('#aa0000')
	base.self_modulate = Color('#aa0000')
	if get_tree() == null:
		return
	await get_tree().create_timer(0.2).timeout
	health -= dmg
	if health <= 0:
		queue_free()
	head.self_modulate = Color('#ffffff')
	base.self_modulate = Color('#ffffff')

#func _on_shooting_area_body_entered(body):
	#if body.name != 'Player': return	
	#player = body
	#state = 'hostile'
#
#
#func _on_shooting_area_body_exited(body):
	#if body.name != 'Player': return
	#player = body
	#state = 'idle'
	#shoot_ready = false
	#aim_timer = 0
