extends Node2D

@onready var flatland_collider = $Flatland/FlatlandCollider
@onready var flatland_polygon = $Flatland/FlatlandCollider/FlatlandPolygon

@onready var testland_collider = $Testland/TestlandCollider
@onready var testland_polygon = $Testland/TestlandCollider/TestlandPolygon

@onready var camera_2d = $Camera2D
@onready var player = $Player

@onready var world_map = $WorldMap
@onready var world_borders = $WorldBorders


var floor = preload('res://scene/phase2/platforms/bottom_floor.tscn')
# Called when the node enters the scene tree for the first time.
func _ready():
	# set bg color
	RenderingServer.set_default_clear_color(Color.BLACK)
	# display testing platforms
	flatland_polygon.polygon = flatland_collider.polygon
	testland_polygon.polygon = testland_collider.polygon
	# set player camera
	player.camera = camera_2d
	#generate_world_borders()
	

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
		

