extends Sprite2D

var hovering = false
var clicking = false
const BUTTON_2 = preload("res://button2.png")
const BUTTON_1 = preload('res://button1.png')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hovering and Input.is_action_just_released("select"):
		Audio.play_sfx('button')
		get_parent().get_parent().go_to_shop()
		#get_tree().change_scene_to_file("res://scene/phase1/shop.tscn")
	
	if Input.is_action_just_released('select'):
		texture = BUTTON_1
	
	if hovering and Input.is_action_just_pressed('select'):
		clicking = true
		texture = BUTTON_2

func _on_h_box_container_mouse_entered():
	hovering = true


func _on_h_box_container_mouse_exited():
	hovering = false
