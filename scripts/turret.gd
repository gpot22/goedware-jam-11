extends StaticBody2D

# ATTRIBUTES
var health
var state = 'idle'
var player = null
var damage = 20

# STUFF
@onready var base = $body/base
@onready var head = $body/HeadAnchor/head
@onready var bullet_spawn = $body/HeadAnchor/head/BulletSpawn
@onready var line_of_sight = $body/HeadAnchor/head/BulletSpawn/LineOfSight

var bullet = preload('res://scene/phase2/turret_bullet.tscn')

var charging = false
var shoot_ready = false
var charge = 0
var MAX_CHARGE = 4
var charge_ready = true
var aim_timer = 0
var aim_time_max = 40
var aim_ready = true

func _physics_process(delta):
	if not charging and not shoot_ready and charge_ready:
		charge_up()
	if state == 'hostile':
		if (not shoot_ready or aim_timer > 30) and aim_ready:
			aim_at_player()
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
	update_animations()
	
func update_animations():
	if state == 'idle':
		head.play('idle')
		line_of_sight.visible = false
	else:
		line_of_sight.visible = true
		#if charge == 0:
			#base.play('idle')
		#else:
			#base.play('charge' + str(charge))
		
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
	line = (line / line.length()) * bullet_spawn.global_position.distance_to(player_center)*0.6
	line_of_sight.points[1] = line
		
func burst_shoot(n=3):
	if line_of_sight.visible:
		line_of_sight.width = 4
		line_of_sight.default_color = Color('#ff463cc8')
	aim_ready = false
	for i in range(n):
		shoot()
		await get_tree().create_timer(0.1).timeout
	aim_ready = true
	if line_of_sight.visible:
		line_of_sight.width = 2
		line_of_sight.default_color = Color('#ff463c78')
	#await get_tree().create_timer(1.2-0.4).timeout

func toggle_line_color():
	if line_of_sight.default_color == Color('#ff463c78'):
		line_of_sight.default_color = Color('#ff463c40')
	else:
		line_of_sight.default_color = Color('#ff463c78')
		
func shoot():
	var b = bullet.instantiate()
	b.global_position = bullet_spawn.global_position
	b.global_rotation = bullet_spawn.global_rotation
	add_child(b)
	head.play('shoot')
	await head.animation_finished
	head.stop()
	#anim_sprite.play('shoot')
	
func charge_up():
	var t = 0.6
	charging = true
	await get_tree().create_timer(0.8).timeout
	#var idle_interrupt = false
	if charge < 4:
		for i in range(charge+1, MAX_CHARGE+1):
			charge += 1
			base.play('charge' + str(i))
			await get_tree().create_timer(t).timeout
			base.stop()
	#if idle_interrupt: return
	charging = false
	aim_timer = aim_time_max
	shoot_ready = true
	

func _on_shooting_area_body_entered(body):
	if body.name != 'Player': return	
	player = body
	state = 'hostile'


func _on_shooting_area_body_exited(body):
	if body.name != 'Player': return
	player = body
	state = 'idle'
	shoot_ready = false
	aim_timer = 0
