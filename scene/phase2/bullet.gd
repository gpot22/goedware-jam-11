extends 'res://scene/phase2/BulletSuperclass.gd'


func _ready():
	super._ready()
	vel = 2000
	range = 600
	parent = get_parent().get_parent().name  # parent = gun, gun's parent = player or enemy

func isPlayer():
	return parent == "Player"
	
func _on_body_entered(body):
	if isPlayer():
		if body.name == "Player": return
	else:
		if body.name != "Player": return
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()
