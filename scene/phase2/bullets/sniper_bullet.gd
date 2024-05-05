extends 'res://scene/phase2/bullets/BulletSuperclass.gd'

var first_shot = false
func _ready():
	max_l = 2400
	max_w = 3
	super._ready()
	vel = 4500
	range = 10000
	parent = get_parent().get_parent().get_parent().name  # parent = gun, gun's parent = weaponpoint, weaponpoint's parent = player or enemy

func _on_body_entered(body):
	if is_player():
		if body.name == "Player": return
	else:
		if body.name != "Player": return
	if body.has_method("take_damage"):
		if first_shot:
			body.take_damage(get_parent().first_shot_damage)
		else:
			body.take_damage(get_parent().damage)

