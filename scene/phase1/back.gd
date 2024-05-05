extends Sprite2D

var hovering = false
var clicking = false
const BUTTON_2 = preload("res://button2.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hovering and Input.is_action_just_released("select"):
		Audio.play_sfx('button')
		get_tree().change_scene_to_file("res://scene/phase_1_levelgenerator.tscn")
	
	if hovering and Input.is_action_just_pressed('select'):
		clicking = true
		texture = BUTTON_2

func _on_h_box_container_mouse_entered():
	hovering = true


func _on_h_box_container_mouse_exited():
	hovering = false
