extends Node2D

@onready var camera_2d = $Camera2D
@onready var player = $Player

@onready var world_map = $WorldMap
@onready var world_borders = $WorldBorders
@onready var xhair = $xhair
@onready var spawn_points = $SpawnPoints
@onready var health_bar: Sprite2D = $CanvasLayer/HealthBar/bar

var bullet_label: Label

var rng = RandomNumberGenerator.new()
var floor = preload('res://scene/phase2/platforms/bottom_floor.tscn')
const ENEMY_DIR = 'res://scene/phase2/enemies'
var ENEMIES = {
	'beef': preload(ENEMY_DIR + '/enemy_beef.tscn'),
	'bombardier': preload(ENEMY_DIR + '/enemy_bombardier.tscn'),
	'sniper': preload(ENEMY_DIR + '/enemy_sniper.tscn'),
	'turret': preload(ENEMY_DIR + '/turret.tscn')
}
var used_points = []

var zoom_increment = 1.3
var zoom_death_target = 2.0
var zoom_current
var zoom_next
var death_phase_finished = false
var celebrate_phase_finished = false

func _ready():
	bullet_label = $CanvasLayer/Bulletshud/Label
	# set bg color
	RenderingServer.set_default_clear_color(Color.BLACK)
	Input.set_custom_mouse_cursor(xhair.texture.get_frame_texture(0), 0, Vector2(22, 22))
	var test_level = GlobalVariables.phase_2_enemy_count
	for enemy_name in test_level.keys():
		var points = get_spawn_points(enemy_name)
		points.shuffle()
		for i in range(test_level[enemy_name]):
			if len(points) == 0:
				break
			var idx = rng.randi_range(0, len(points)-1)
			print(points[idx])
			points[idx].add_child(ENEMIES[enemy_name].instantiate())
			used_points.append(points[idx])
			points.pop_at(idx)
	zoom_current = camera_2d.zoom.x
func get_spawn_points(enemy):
	var points = []
	for p in spawn_points.get_children():
		if p.get_child_count() != 0: continue
		if not p.name.contains(enemy): continue
		points.append(p)
	return points

func player_dead():
	return player.health <= 0

func enemies_alive():
	return len(get_tree().get_nodes_in_group("Enemy")) != 0
	
var start_phase = false
func player_death_phase(delta):
	player.die()
	while zoom_current < zoom_death_target:
		zoom_current = lerp(zoom_current, zoom_current + zoom_increment, zoom_increment*delta)
		camera_2d.set_zoom(Vector2(zoom_current, zoom_current))
		await get_tree().create_timer(0.01).timeout
	if player.ap.is_playing():
		await player.ap.animation_finished
	death_phase_finished = true

func player_celebrate_phase(delta):
	player.celebrate()
	while zoom_current < zoom_death_target:
		zoom_current = lerp(zoom_current, zoom_current + zoom_increment, zoom_increment*delta)
		camera_2d.set_zoom(Vector2(zoom_current, zoom_current))
		await get_tree().create_timer(0.01).timeout
	if player.ap.is_playing():
		await player.ap.animation_finished
	for i in range(3):
		await player.celebrate_idle()
		if player.ap.is_playing():
			await player.ap.animation_finished
	celebrate_phase_finished = true

func _process(delta):
	# update 
	camera_2d.set_position(Vector2(player.get_position().x, player.get_position().y-35))
	if not enemies_alive() and not start_phase:
		var parent = get_parent()
		start_phase = true
		await player_celebrate_phase(delta)
		if celebrate_phase_finished:
			GlobalVariables.wallet += 1
			GlobalVariables.level += 1
			parent.win()
			parent.go_to_phase_1(false)
	
	update_bullets()
	update_health_bar()
	if player_dead() and not start_phase:
		var parent = get_parent()
		start_phase = true
		await player_death_phase(delta)
		if death_phase_finished:  ### END PHASE 2 HERE
			parent.lost()
			
func update_health_bar():
	var x
	var y = 0
	var w = 160
	var h = 11
	var offset_x
	var health_percent = player.health / player.max_health
	var pixels = max(int(w * health_percent), 0)
	x = pixels - w
	offset_x = pixels - w
	health_bar.region_rect = Rect2(x, y, w, h)
	health_bar.offset = Vector2(offset_x, 0)
	
func update_bullets():
	if player.gun == null:
		return
	bullet_label.text = str(player.gun.current_magazine) + '/' + str(player.gun.magazine)
	
	

