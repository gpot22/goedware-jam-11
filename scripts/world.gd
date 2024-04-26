extends Node2D

@onready var flatland_collider = $Flatland/FlatlandCollider
@onready var flatland_polygon = $Flatland/FlatlandCollider/FlatlandPolygon

@onready var testland_collider = $Testland/TestlandCollider
@onready var testland_polygon = $Testland/TestlandCollider/TestlandPolygon

# Called when the node enters the scene tree for the first time.
func _ready():
	flatland_polygon.polygon = flatland_collider.polygon
	testland_polygon.polygon = testland_collider.polygon



