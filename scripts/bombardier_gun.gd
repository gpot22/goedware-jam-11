extends Node2D

const GRENADE = preload('res://scene/phase2/enemies/grenade.tscn')

const GRENADE_GRAVITY = 800
@onready var bullet_spawn = $AnimatedSprite2D/BulletSpawn
@onready var ap = $AnimatedSprite2D

var target
var grenade_vel
var direction = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#if direction == 1:
		#
	#else:
		
	
func get_grenade_vi(xi, yi, xf, yf):
	var dx = xf - xi
	var dy = yf - yi

	var viy = -800
	var ay = GRENADE_GRAVITY
	
	
	var t =( -viy + sqrt(viy**2 -4*(ay/2)*(-dy)))/(ay)
	
	var vix = dx/t
	return Vector2(vix, viy)
	
func shoot(x_offset=0):
	var grenade = GRENADE.instantiate()
	get_parent().get_parent().add_child(grenade)
	grenade.global_position = bullet_spawn.global_position
	
	var xi = grenade.global_position.x
	var yi = grenade.global_position.y
	
	var xf = target.global_position.x + x_offset
	var yf = target.global_position.y
	
	grenade_vel = get_grenade_vi(xi, yi, xf, yf)
	scale.x = direction
	var v = Vector2(grenade_vel.x*direction, grenade_vel.y)
	#v.y*= direction
	set_global_rotation(v.angle()*direction)
	
	grenade.vel = grenade_vel
	grenade.g = GRENADE_GRAVITY
	
	ap.play('shoot')
	await ap.animation_finished
	ap.stop()
	
	
	
	
	#var vi = dx
	
