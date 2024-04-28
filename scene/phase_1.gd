extends Node2D
@onready var camera_2d = $Camera2D
@onready var tile_map = $TileMap


var viewport_width = 800.0
var viewport_height = 450.0
var camera_state = 'in'
var cam_pos_x = viewport_width/2
var cam_pos_y = viewport_height/2
var previous_cam_pos_x = 0
var previous_cam_pos_y = 0
var single_tile_size
var total_x_tiles
var total_y_tiles
var total_map_size_x
var total_map_size_y
var tile_scale = 1
var previous_tile_x = -1
var previous_tile_y = -1
var clicking = false
var selected_tiles = []

# Called when the node enters the scene tree for the first time.
func _ready():
	single_tile_size = tile_map.tile_set.tile_size.x * tile_scale
	total_x_tiles = tile_map.get_used_rect().size.x
	total_y_tiles = tile_map.get_used_rect().size.y
	total_map_size_x = total_x_tiles * single_tile_size
	total_map_size_y = total_y_tiles * single_tile_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_camera()
	handle_mouse()

func handle_mouse():
	var mouse_x = get_global_mouse_position().x
	var mouse_y = get_global_mouse_position().y
	var tile_x = int(mouse_x / single_tile_size)
	var tile_y = int(mouse_y / single_tile_size)
	
	# hover
	#if previous_tile_x != tile_x or previous_tile_y != tile_y:
		#if clicking:
			#selected_tiles.append(Vector2i(tile_x, tile_y))
		#else:
			#tile_map.set_cell(0, Vector2i(tile_x, tile_y), 0, Vector2i(6,1))
			#tile_map.set_cell(0, Vector2i(previous_tile_x, previous_tile_y), 0, Vector2i(8,0))
		#previous_tile_x = tile_x
		#previous_tile_y = tile_y
	
	if Input.is_action_just_pressed('select'):
		selected_tiles.append(Vector2i(previous_tile_x, previous_tile_y))
		tile_map.set_cell(0, Vector2i(previous_tile_x, previous_tile_y), 0, Vector2i(2,0))
		clicking = true
	
	if clicking:
		if previous_tile_x != tile_x or previous_tile_y != tile_y:
			if tile_x == previous_tile_x: # extend along y
				for i in range(total_y_tiles):
					tile_map.set_cell(0, Vector2i(selected_tiles[0].x, i), 0, Vector2i(1,0))
			elif tile_y == previous_tile_y: # extend along x
				for i in range(total_x_tiles):
					tile_map.set_cell(0, Vector2i(i, selected_tiles[0].y), 0, Vector2i(1, 0))
		
	if Input.is_action_just_released('select'):
		clicking = false
	#if clicking:
		#for i in selected_tiles:
			#tile_map.set_cell(0, i, 0, Vector2i(2,0))
	previous_tile_x = tile_x
	previous_tile_y = tile_y

func handle_camera():
	# default viewport = 800x450
	if Input.is_action_just_pressed("swapcamera"):
		if camera_state == 'in':
			previous_cam_pos_x = cam_pos_x
			previous_cam_pos_y = cam_pos_y
			cam_pos_x = total_map_size_x/2
			cam_pos_y = total_map_size_y/2
			camera_2d.zoom = Vector2(viewport_width/total_map_size_x, viewport_height/total_map_size_y)
			camera_state = 'out'
		else:
			cam_pos_x = previous_cam_pos_x
			cam_pos_y = previous_cam_pos_y
			camera_2d.zoom = Vector2(1, 1)
			camera_state = 'in'
		camera_2d.set_position(Vector2(cam_pos_x, cam_pos_y))
	var directionLR = Input.get_axis('panleft', 'panright')
	var directionUD = Input.get_axis('panup', 'pandown')
	if camera_state == 'in':
		if directionLR == 1:
			if cam_pos_x + viewport_width/2 + 3 <= total_map_size_x:
				cam_pos_x += 3
		if directionLR == -1:
			if cam_pos_x - viewport_width/2 - 3 >= 0:
				cam_pos_x -= 3
		if directionUD == 1:
			if cam_pos_y + viewport_height/2 + 3 <= total_map_size_y:
				cam_pos_y += 3
		if directionUD == -1:
			if cam_pos_y - viewport_height/2 - 3 >= 0:
				cam_pos_y -= 3
		
		if directionLR != 0 or directionUD != 0:
			camera_2d.set_position(Vector2(cam_pos_x, cam_pos_y))
