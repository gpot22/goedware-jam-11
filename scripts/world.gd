extends Node2D

@onready var camera_2d = $Camera2D
@onready var player = $Player

@onready var world_map = $WorldMap
@onready var world_borders = $WorldBorders
@onready var xhair = $xhair
@onready var spawn_points = $SpawnPoints

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

var zoom_increment = 0.5
var zoom_death_target = 2.0
var zoom_current
var zoom_next
var death_phase_finished = false

func _ready():
	# set bg color
	RenderingServer.set_default_clear_color(Color.BLACK)
	Input.set_custom_mouse_cursor(xhair.texture.get_frame_texture(0), 0, Vector2(22, 22))
	var test_level = GlobalVariables.phase_2_enemy_count
	for enemy_name in test_level.keys():
		var points = get_spawn_points(enemy_name)
		points.shuffle()
		for i in range(test_level[enemy_name]):
			var idx = rng.randi_range(0, len(points)-1-i)
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
	for p in used_points:
		if p.get_child_count() != 0: return true
	return false
		
func player_death_phase(delta):
	var safety = 0
	while zoom_current < zoom_death_target:
		safety += 1
		zoom_current = lerp(zoom_current, zoom_current + zoom_increment, zoom_increment*delta)
		camera_2d.set_zoom(Vector2(zoom_current, zoom_current))
		await get_tree().create_timer(0.01).timeout
	death_phase_finished = true

func _process(delta):
	# update 
	camera_2d.set_position(Vector2(player.get_position().x, player.get_position().y-35))
	if not enemies_alive():
		GlobalVariables.wallet += 1
		GlobalVariables.level += 1
		
	if player_dead():
		player_death_phase(delta)
		if death_phase_finished:
			pass

