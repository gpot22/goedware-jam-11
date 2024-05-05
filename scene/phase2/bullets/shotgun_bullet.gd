extends 'res://scene/phase2/bullets/bullet.gd'

func _ready():
	max_l = 20
	max_w = 4
	super._ready()
	vel = 1000
	range = 200
	parent = get_parent().get_parent().get_parent().name  # parent = gun, gun's parent = weaponpoint, weaponpoint's parent = player or enemy

func _on_body_entered(body):
	if is_player():
		if body.name == "Player": return
	else:
		if body.name != "Player": return
	if body.has_method("take_damage"):
		body.take_damage(get_parent().damage)

