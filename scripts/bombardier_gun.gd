extends 'res://scripts/WeaponSuperclass.gd'

func _ready():
	super._ready()
	bullet = preload('res://scene/phase2/enemies/grenade.tscn')
	direction = -1
	damage = 30
	shot_time = 0.35
	
	
func _physics_process(delta):
	pass
	
func shoot(vel=null, x_offset=0):
	var grenade = bullet.instantiate()
	get_parent().get_parent().get_parent().add_child(grenade)
	grenade.global_position = bullet_spawn.global_position

	set_global_rotation(vel.angle())
	if direction == -1:
		scale.y = -1
	else:
		scale.y = 1
	
	grenade.vel = vel
	
	anim_sprite.play('shoot')
	await anim_sprite.animation_finished
	anim_sprite.stop()
	
	
	
	
	#var vi = dx
	
