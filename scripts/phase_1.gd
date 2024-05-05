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
@onready var shopbutton = $shopbutton
@onready var info = $info
@onready var tint = $tint
@onready var line = $Line2D
@onready var slices = $slices
@onready var level_indicator = $level_indicator

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
var x_offset = 225
var y_offset = 100
var dropping = false
var lock = false
var total_isolations = 0
var remaining_isolations = 0
var level

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
	slices.text = 'Isolations: ' + str(remaining_isolations)
	level_indicator.text = 'Level: ' + str(level)
	info.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_mouse()
	if lock:
		handle_tint()
	else:
		line.visible = false
		
func get_islands():
	var separated_corners = []
	var x = [-1]
	var y = [-1]
	for i in range(total_x_tiles):
		if tiles[0][i].visible == false:
			x.append(i)
	for i in range(total_y_tiles):
		if tiles[i][0].visible == false:
			y.append(i)
	
	x.append(total_x_tiles)
	y.append(total_y_tiles)
	
	for i in range(1, x.size()):
		for j in range(1, y.size()):
			separated_corners.append([[x[i-1]+1, y[j-1]+1], [x[i]-1, y[j]-1]])
	
	return separated_corners
		
func handle_tint():
	var mouse = get_global_mouse_position()
	var mouse_x = mouse.x
	var mouse_y = mouse.y
	var tile_x = (mouse_x - x_offset + (single_tile_size_x) / 2) / (single_tile_size_x + x_gap)
	var tile_y = (mouse_y - y_offset + (single_tile_size_y) / 2) / (single_tile_size_y + y_gap)
	
	if tile_x > total_x_tiles or tile_y > total_y_tiles:
		line.visible = false
		return
	if tile_x < 0 or tile_y < 0:
		line.visible = false
		return
	
	tile_x = int(tile_x)
	tile_y = int(tile_y)
	
	var separated_corners = get_islands()
	for j in separated_corners:
		if tile_x >= j[0][0] and tile_x <= j[1][0] and tile_y >= j[0][1] and tile_y <= j[1][1]:
			line.width = ((j[1][1]+1.2) * single_tile_size_y + (j[1][1]+1.2) * y_gap) - ((j[0][1]) * single_tile_size_y + (j[0][1]) * y_gap)
			line.points = PackedVector2Array([Vector2(x_offset + (single_tile_size_x + x_gap) * j[0][0] - single_tile_size_x / 2, y_offset + (single_tile_size_y + y_gap) * j[0][1] + line.width / 2 - single_tile_size_y / 2), Vector2(x_offset + (single_tile_size_x + x_gap) * j[1][0] + single_tile_size_x / 2, y_offset + (single_tile_size_y + y_gap) * j[0][1] + line.width / 2  - single_tile_size_y / 2)])
			line.visible = true
			line.z_index = 66
			line.modulate = Color(1, 1, 1, 0.5)
			return
	
	line.visible = false

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
			a.visible = true
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
	if lock:
		return
	
	var mouse = get_global_mouse_position()
	var mouse_x = mouse.x
	var mouse_y = mouse.y
	var tile_x = (mouse_x - x_offset + (single_tile_size_x) / 2) / (single_tile_size_x + x_gap)
	var tile_y = (mouse_y - y_offset + (single_tile_size_y) / 2) / (single_tile_size_y + y_gap)
	
	if tile_x > total_x_tiles or tile_y > total_y_tiles:
		return
	if tile_x < 0 or tile_y < 0:
		return
	
	tile_x = int(tile_x)
	tile_y = int(tile_y)
	
	if Input.is_action_just_pressed('select'):
		if remaining_isolations == 0:
			for j in range(3):
				for i in range(total_y_tiles-1, -1, -1):
					slices.modulate = Color('#ff5640')
				await get_tree().create_timer(0.1).timeout
				for i in range(total_y_tiles-1, -1, -1):
					slices.modulate = Color('#ffffff')
				await get_tree().create_timer(0.1).timeout
			return
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
						remaining_isolations -= 1
						slices.text = 'Isolations: ' + str(remaining_isolations)
						for i in range(total_y_tiles-1, -1, -1):
							if tiles[i][selected_tiles[0].x].visible != false:
								tiles[i][selected_tiles[0].x].visible = false
								brokentiles[i][selected_tiles[0].x].visible = true
								brokentiles[i][selected_tiles[0].x].drop()
								await get_tree().create_timer(0.2).timeout
					else:
						for j in range(3):
							for i in range(total_y_tiles-1, -1, -1):
								tiles[i][selected_tiles[0].x].modulate = Color('#ff5640')
							await get_tree().create_timer(0.1).timeout
							for i in range(total_y_tiles-1, -1, -1):
								tiles[i][selected_tiles[0].x].modulate = Color('#ffffff')
							await get_tree().create_timer(0.1).timeout
				elif selected_tiles[0].y == selected_tiles[1].y: # extend along x
					if int(selected_tiles[0].y) not in y_tiles_with_enemies:
						remaining_isolations -= 1
						slices.text = 'Isolations: ' + str(remaining_isolations)
						for i in range(total_x_tiles):
							if tiles[selected_tiles[0].y][i].visible != false:
								tiles[selected_tiles[0].y][i].visible = false
								brokentiles[selected_tiles[0].y][i].visible = true
								brokentiles[selected_tiles[0].y][i].drop()
								await get_tree().create_timer(0.2).timeout
					else:
						for j in range(3):
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

func reset_level():
	for i in tiles.size():
		for j in tiles[i]:
			j.queue_free()
	tiles.clear()
		
	for i in brokentiles.size():
		for j in brokentiles[i]:
			j.queue_free()
	brokentiles.clear()
	
	lock = false
	remaining_isolations = total_isolations
	slices.text = 'Isolations: ' + str(remaining_isolations)
	generate_tiles()

func handle_info(enemy, visible):
	if visible:
		if enemy in GlobalVariables.discovered_enemies:
			info.get_child(1).modulate = Color(1, 1, 1, 1)
		else:
			info.get_child(1).modulate = Color(0, 0, 0, 1)
		if enemy == 'beef':
			info.get_child(1).animation = 'beef'
			info.get_child(1).position = Vector2(84, -43.5)
			info.get_child(2).text = 'Beef are common soldiers that succeed through sheer force. Their resilience lets them soak up incoming damage that allows their fellow comrades to unleash powerful attacks.'
		elif enemy == 'bombardier':
			info.get_child(1).animation = 'bombardier'
			info.get_child(1).position = Vector2(82, -31.2)
			info.get_child(2).text = 'Bombardiers are dangerous rogues that shower the area with explosive ordinance. Their grenade launcher spews several explosives that create hazardous areas wherever you might be. Due to their curious nature, they will eventually want to take “a closer look”.'
		elif enemy == 'sniper':
			info.get_child(1).animation = 'sniper'
			info.get_child(1).position = Vector2(98, -34.4)
			info.get_child(2).text = 'Snipers are efficient shooters that will attack you from across any distance. Despite carrying heavy equipment, Snipers are excellent at moving through their environment, firing devastating shots with surgical precision.'
		elif enemy == 'turret':
			info.get_child(1).animation = 'turret'
			info.get_child(1).position = Vector2(71, -32.2)
			info.get_child(2).text = 'Turrets are lethal machines that are designed to shut down any hostility in its proximity. After a brief charge up period, an endless hail of high calibre bullets is sure to neutralize whatever threat stands in its way. Clad in bulletproof material, the turret tanks a ridiculous amount of damage before it will expire.'
		info.visible = true
	else:
		info.visible = false

func toggle_lock():
	lock = !lock
