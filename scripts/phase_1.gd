extends Node2D
@onready var camera_2d = $Camera2D
@onready var tile_map = $TileMap
@onready var arrows_sprite = $arrows
@onready var beef = preload("res://scene/phase1/beef.tscn")
@onready var sniper = preload("res://scene/phase1/sniper.tscn")
@onready var bombardier = preload("res://scene/phase1/bombardier.tscn")
@onready var turret = preload("res://scene/phase1/turret.tscn")
@onready var brokentile = preload("res://scene/phase1/brokentile.tscn")
@onready var tile = preload("res://scene/phase1/tile.tscn")
@onready var tile_example = $tile

var single_tile_size_x
var single_tile_size_y
var previous_tile_x = -1
var previous_tile_y = -1
var selected_tiles = [Vector2(-1, -1), Vector2(-1, -1)]
var clicking = false
var enemy_types = ['beef', 'sniper', 'bombardier', 'turret']
var tiles_with_enemies = {'beef': [], 'sniper': [], 'bombardier': [], 'turret': []}
var x_tiles_with_enemies = []
var y_tiles_with_enemies = []
var brokentiles = []
var tiles = []
var total_x_tiles = 8
var total_y_tiles = 8
var x_gap = 2
var y_gap = -8
var x_offset = 240
var y_offset = 100
var dropping = false

# Called when the node enters the scene tree for the first time.
func _ready():
	single_tile_size_x = tile_example.get_child(0).texture.get_size().x
	single_tile_size_y = tile_example.get_child(0).texture.get_size().y
	
	for i in enemy_types:
		for j in tiles_with_enemies[i]:
			x_tiles_with_enemies.append(j[0])
			y_tiles_with_enemies.append(j[1])
	
	arrows_sprite.z_index = total_x_tiles * total_y_tiles
	
	generate_tiles()
	generate_enemies()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_mouse()

func generate_enemies():
	for i in tiles_with_enemies['beef']:
		var a = beef.instantiate()
		a.set_position(Vector2(x_offset + i[0] * (single_tile_size_x + x_gap), y_offset + i[1] * (single_tile_size_y + y_gap) - 21))
		a.visible = true
		a.z_index = total_x_tiles * total_y_tiles
		add_child(a)
	for i in tiles_with_enemies['bombardier']:
		var a = bombardier.instantiate()
		a.set_position(Vector2(x_offset + i[0] * (single_tile_size_x + x_gap) + 1, y_offset + i[1] * (single_tile_size_y + y_gap) - 16))
		a.visible = true
		a.z_index = total_x_tiles * total_y_tiles
		add_child(a)
	for i in tiles_with_enemies['sniper']:
		var a = sniper.instantiate()
		a.set_position(Vector2(x_offset + i[0] * (single_tile_size_x + x_gap) - 4, y_offset + i[1] * (single_tile_size_y + y_gap) - 18))
		a.visible = true
		a.z_index = total_x_tiles * total_y_tiles
		add_child(a)
	for i in tiles_with_enemies['turret']:
		var a = turret.instantiate()
		a.set_position(Vector2(x_offset + i[0] * (single_tile_size_x + x_gap) - 11, y_offset + i[1] * (single_tile_size_y + y_gap) - 15))
		a.visible = true
		a.z_index = total_x_tiles * total_y_tiles
		add_child(a)

func generate_tiles():
	var count = 0
	for i in range(total_x_tiles):
		tiles.append([])
		for j in range(total_y_tiles):
			var a = tile.instantiate()
			tiles[i].append(a)
			if j > 6:
				a.set_position(Vector2(x_offset + j * single_tile_size_x + x_gap * j - 1, y_offset + i * single_tile_size_y + y_gap * i))
			elif j >= 3:
				a.set_position(Vector2(x_offset + j * single_tile_size_x + x_gap * j - 0.5, y_offset + i * single_tile_size_y + y_gap * i))
			else:
				a.set_position(Vector2(x_offset + j * single_tile_size_x + x_gap * j, y_offset + i * single_tile_size_y + y_gap * i))
			#a.set_position(Vector2(x_offset + j * single_tile_size_x + x_gap * j, y_offset + i * single_tile_size_y + y_gap * i))
			a.z_index = count
			add_child(a)
			count += 1
	
	count = 0
	
	for i in range(total_x_tiles):
		brokentiles.append([])
		for j in range(total_y_tiles):
			var a = brokentile.instantiate()
			brokentiles[i].append(a)
			if j > 6:
				a.set_position(Vector2(x_offset + j * single_tile_size_x + x_gap * j - 1, y_offset + i * single_tile_size_y + y_gap * i))
			elif j >= 3:
				a.set_position(Vector2(x_offset + j * single_tile_size_x + x_gap * j - 0.5, y_offset + i * single_tile_size_y + y_gap * i))
			else:
				a.set_position(Vector2(x_offset + j * single_tile_size_x + x_gap * j, y_offset + i * single_tile_size_y + y_gap * i))
			#a.set_position(Vector2(x_offset + j * single_tile_size_x + x_gap * j, y_offset + i * single_tile_size_y + y_gap * i))
			a.z_index = count
			a.visible = false
			add_child(a)
			count += 1

func handle_mouse():
	var mouse = get_global_mouse_position()
	var mouse_x = mouse.x
	var mouse_y = mouse.y
	var tile_x = int((mouse_x - x_offset + (single_tile_size_x) / 2) / (single_tile_size_x + x_gap))
	var tile_y = int((mouse_y - y_offset + (single_tile_size_y) / 2) / (single_tile_size_y + y_gap))
	
	if tile_x > total_x_tiles-1 or tile_y > total_y_tiles:
		return
	
	if Input.is_action_just_pressed('select'):
		if tiles[tile_y][tile_x].visible == false or dropping:
			return
		arrows_sprite.set_position(Vector2(x_offset + tile_x * (single_tile_size_x + x_gap), y_offset + tile_y * (single_tile_size_y + y_gap) - 7))
		selected_tiles[0] = Vector2(tile_x, tile_y)
		arrows_sprite.visible = true
		clicking = true
	
	if selected_tiles[0].x != -1 and Vector2(previous_tile_x, previous_tile_y) != Vector2(tile_x, tile_y):
		selected_tiles[1] = Vector2(tile_x, tile_y)
	
	if Input.is_action_just_released('select'):
		if clicking and not dropping:
			if selected_tiles[1].x != -1:
				dropping = true
				arrows_sprite.visible = false
				if selected_tiles[0].x == selected_tiles[1].x: # extend along y
					if int(selected_tiles[0].x) not in x_tiles_with_enemies:
						for i in range(total_y_tiles-1, -1, -1):
							tiles[i][selected_tiles[0].x].visible = false
							brokentiles[i][selected_tiles[0].x].visible = true
							brokentiles[i][selected_tiles[0].x].drop()
							await get_tree().create_timer(0.2).timeout
					else:
						for j in range(4):
							for i in range(total_y_tiles-1, -1, -1):
								tiles[i][selected_tiles[0].x].modulate = Color('#ff5640')
							await get_tree().create_timer(0.1).timeout
							for i in range(total_y_tiles-1, -1, -1):
								tiles[i][selected_tiles[0].x].modulate = Color('#ffffff')
							await get_tree().create_timer(0.1).timeout
				elif selected_tiles[0].y == selected_tiles[1].y: # extend along x
					if int(selected_tiles[0].y) not in y_tiles_with_enemies:
						for i in range(total_x_tiles):
							tiles[selected_tiles[0].y][i].visible = false
							brokentiles[selected_tiles[0].y][i].visible = true
							brokentiles[selected_tiles[0].y][i].drop()
							await get_tree().create_timer(0.2).timeout
					else:
						for j in range(4):
							for i in range(total_x_tiles):
								tiles[selected_tiles[0].y][i].modulate = Color('#ff5640')
							await get_tree().create_timer(0.1).timeout
							for i in range(total_x_tiles):
								tiles[selected_tiles[0].y][i].modulate = Color('#ffffff')
							await get_tree().create_timer(0.1).timeout
				dropping = false
			selected_tiles = [Vector2(-1, -1), Vector2(-1, -1)]
		clicking = false
	
	previous_tile_x = tile_x
	previous_tile_y = tile_y
