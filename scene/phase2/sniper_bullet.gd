extends 'res://scene/phase2/bullet.gd'

func _ready():
	max_w = 140
	max_h = 1
	super._ready()
	vel = 3000
	range = 1000
	parent = get_parent().get_parent().get_parent().name  # parent = gun, gun's parent = weaponpoint, weaponpoint's parent = player or enemy

#func is_player():
	#return parent == "Player"
	#
#func _on_body_entered(body):
	#if is_player():
		#if body.name == "Player": return
	#else:
		#if body.name != "Player": return
	#queue_free()
	#if body.has_method("take_damage"):
		#body.take_damage()
