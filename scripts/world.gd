extends Node2D

@onready var flatland_collider = $Flatland/FlatlandCollider
@onready var flatland_polygon = $Flatland/FlatlandCollider/FlatlandPolygon

@onready var testland_collider = $Testland/TestlandCollider
@onready var testland_polygon = $Testland/TestlandCollider/TestlandPolygon

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

# Called when the node enters the scene tree for the first time.
func _ready():
	# set bg color
	RenderingServer.set_default_clear_color(Color.BLACK)
	## set player camera
	Input.set_custom_mouse_cursor(xhair.texture.get_frame_texture(0), 0, Vector2(22, 22))
	var test_level = GlobalVariables.phase_2_enemies
	for enemy_name in test_level.keys():
		var points = get_spawn_points(enemy_name)
		points.shuffle()
		for i in range(test_level[enemy_name]):
			var idx = rng.randi_range(0, len(points)-1-i)
			points[idx].add_child(ENEMIES[enemy_name].instantiate())
			points.pop_at(idx)
		
func get_spawn_points(enemy):
	var points = []
	for p in spawn_points.get_children():
		if p.get_child_count() != 0: continue
		if not p.name.contains(enemy): continue
		points.append(p)
	return points
		
	
func _process(delta):
	# update 
	camera_2d.set_position(Vector2(player.get_position().x, player.get_position().y-35))

#func generate_world_borders():
	#var border_bottom_width = 20
	#var border_side_height = 20
	#var floor_y = 1440
	##var 
	#for i in range(border_bottom_width):
		#var tile = floor.instantiate()
		#var w = tile.get_child(0).shape.get_rect().size.x
		##tile.absolute_position.x
		#world_borders.add_child(tile)
		##tile.absolute_position.x = w * i + w/2
		#tile.global_position = Vector2(w*i+int(w/2), floor_y)
		#print(Vector2(w*i+w/2, floor_y))
		#
	#for i in range(border_side_height):
		#var tile = floor.instantiate()
		##tile.r
		

