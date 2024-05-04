extends Node2D

# Weapon relevant characters
var parent  # weapon holder
var target  # weapon target

# Weapon Attributes
var direction
var anim_sprite: AnimatedSprite2D
var bullet_spawn
var bullet

# WEAPON STATS
var damage
var shot_time

# Weapon States
var active

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_sprite = $WeaponPivot/AnimatedSprite2D
	bullet_spawn = $WeaponPivot/AnimatedSprite2D/BulletSpawn
	direction = 1
	active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
	
func toggle_active(a):
	set_visible(a)
	active = a
	
func shoot():
	pass
	
func is_player():
	return parent.name == 'Player'
	
func set_direction(d):
	anim_sprite.flip_h = (d == -1)
	
func point_to_target(vec2):
	look_at(vec2)
	bullet_spawn.look_at(vec2)
