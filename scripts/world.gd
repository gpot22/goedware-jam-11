extends Node2D

@onready var flatland_collider = $Flatland/FlatlandCollider
@onready var flatland_polygon = $Flatland/FlatlandCollider/FlatlandPolygon


# Called when the node enters the scene tree for the first time.
func _ready():
	flatland_polygon.polygon = flatlond_collider.polygon



