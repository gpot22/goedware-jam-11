extends Area2D

var vel
var range
var travelled_distance = 0
var direction
var parent
var max_w = 30
var max_h = 5

@onready var shape: Polygon2D = $Polygon2D
@onready var light: PointLight2D = $PointLight2D

func _ready():
	set_shape(max_w, max_h)
	

func _physics_process(delta):
	direction = Vector2.RIGHT.rotated(rotation)
	position += direction * vel * delta
	
	travelled_distance += vel * delta
	if travelled_distance > range:
		#print('hi')
		queue_free()
	#print(travelled_distance)
	#print(range/5)
	#if int(travelled_distance) % int(range/5) == 0:
		#print('hi')
	var f = 1-travelled_distance/range
	var w = max_w * f
	var h = max_h * f
	set_shape(w, h)
		
	
func set_shape(width, height):
	var x = width/2
	var y = height/2
	var arr = PackedVector2Array([
		Vector2(-x, -y),
		Vector2(x, -y),
		Vector2(x, y),
		Vector2(-x, y)
	])
	shape.polygon = arr
	
	
