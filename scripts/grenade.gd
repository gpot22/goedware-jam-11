extends Area2D

var vel
var g
var r_spd

var explosion_effect = preload('res://scene/vfx/explosion.tscn')
# Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new()
	r_spd = rng.randi_range(100, 300)
	$AnimatedSprite2D.play()
	#linear_velocity.x = 100 # Replace with function body.
	#linear_velocity.y = -2000


func _physics_process(delta):
	if not vel: return
	global_position += vel * delta
	vel.y += g * delta



func _on_body_entered(body):
	var explosion = explosion_effect.instantiate()
	get_parent().get_parent().add_child(explosion)
	explosion.global_position = global_position
	queue_free()
	
