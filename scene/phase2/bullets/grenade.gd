extends Area2D

var vel
var GRAVITY = 800
var r_spd

var explosion_effect = preload('res://scene/vfx/explosion.tscn')

var from_player = false

@onready var explosion_radius = $ExplosionRadius

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
	vel.y += GRAVITY * delta

func explode_damage():
	if !explosion_radius.has_overlapping_bodies(): return
	for body in explosion_radius.get_overlapping_bodies():
		if from_player and body.name == 'Player': return
		if not from_player and body.name != 'Player': return
		var v: Vector2 = body.global_position - explosion_radius.global_position

		var dmg = get_dmg(v.length())
		if body.has_method('take_damage'):
			body.take_damage(dmg)

func get_dmg(r):
	var attrs = [
		{'r': 70, 'dmg': 60},
		{'r': 110, 'dmg': 40},
		{'r': 140, 'dmg': 20}
	]
	for val in attrs:
		if r < val["r"]:
			return val["dmg"]
	return attrs[-1]["dmg"]
	
func _on_body_entered(body):
	var explosion = explosion_effect.instantiate()
	get_parent().get_parent().add_child(explosion)
	explosion.global_position = global_position
	explode_damage()
	Audio.play_sfx('explosion1')
	queue_free()
	
