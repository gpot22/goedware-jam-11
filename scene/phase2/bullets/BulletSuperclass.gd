extends Area2D

var vel
var range
var travelled_distance = 0
var direction
var parent
var max_l = 30
var max_w = 5

@onready var shape: Line2D = $Line2D

func _ready():
	set_shape(max_l, max_w)
	
	

func _physics_process(delta):
	direction = Vector2.RIGHT.rotated(rotation)
	position += direction * vel * delta
	
	travelled_distance += vel * delta
	if travelled_distance > range:
		queue_free()
	var f = 1-travelled_distance/range
	var l = max_l
	var w = max_w * f
	set_shape(l, w)
		
	
func set_shape(length, width):
	shape.width = width
	shape.points = PackedVector2Array([
		Vector2(0, 0),
		Vector2(length, 0)
	])
	#var x = width/2
	#var y = height/2
	#var arr = PackedVector2Array([
		#Vector2(-x, -y),
		#Vector2(x, -y),
		#Vector2(x, y),
		#Vector2(-x, y)
	#])
	#shape.polygon = arr
	
	
