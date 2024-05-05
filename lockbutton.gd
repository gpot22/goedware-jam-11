extends Sprite2D

var hovering = false
var clicking = false
const BUTTON_2 = preload("res://button2.png")
const BUTTON_1 = preload("res://button1.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hovering and Input.is_action_just_released("select"):
		get_parent().toggle_lock()
	
	if hovering and Input.is_action_just_pressed('select'):
		clicking = true
		if texture == BUTTON_1:
			texture = BUTTON_2
		else:
			texture = BUTTON_1

func _on_h_box_container_mouse_entered():
	hovering = true


func _on_h_box_container_mouse_exited():
	hovering = false
