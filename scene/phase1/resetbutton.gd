extends Sprite2D

var hovering = false
var clicking = false
const BUTTON_2 = preload("res://restartbutton2.png")
const BUTTON_1 = preload("res://restartbutton1.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hovering and Input.is_action_just_released("select"):
		Audio.play_sfx('button')
		texture = BUTTON_1
		get_parent().reset_level()
	
	if hovering and Input.is_action_just_pressed('select'):
		clicking = true
		texture = BUTTON_2


func _on_control_mouse_entered():
	hovering = true


func _on_control_mouse_exited():
	hovering = false
