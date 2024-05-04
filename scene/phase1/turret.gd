extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_control_mouse_entered():
	get_parent().handle_info('turret', true)


func _on_control_mouse_exited():
	get_parent().handle_info('turret', false)
