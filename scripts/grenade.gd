extends Area2D

var vel
var g
var r_spd
# Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new()
	r_spd = rng.randi_range(100, 300)
	#linear_velocity.x = 100 # Replace with function body.
	#linear_velocity.y = -2000


func _physics_process(delta):
	if not vel: return
	global_position += vel * delta
	vel.y += g * delta
	$Sprite2D.rotation_degrees+= r_spd*delta
