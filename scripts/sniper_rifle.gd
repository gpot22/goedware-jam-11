extends Node2D

@onready var bullet_spawn = $WeaponPivot/AnimatedSprite2D/BulletSpawn
@onready var ap = $WeaponPivot/AnimatedSprite2D

var parent
var target
var grenade_vel
var direction = 1



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
