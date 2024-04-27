extends Node2D

@onready var flatland_collider = $Flatland/FlatlandCollider
@onready var flatland_polygon = $Flatland/FlatlandCollider/FlatlandPolygon

@onready var testland_collider = $Testland/TestlandCollider
@onready var testland_polygon = $Testland/TestlandCollider/TestlandPolygon

@onready var camera_2d = $Camera2D
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	flatland_polygon.polygon = flatland_collider.polygon
	testland_polygon.polygon = testland_collider.polygon

func _process(delta):
	camera_2d.set_position(Vector2(player.get_position().x, player.get_position().y-35))


