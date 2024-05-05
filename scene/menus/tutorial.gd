extends Node2D

var hovering = false
@onready var control = $Control
@onready var control_2 = $Control2
@onready var control_3 = $Control3
@onready var label = $Control/Label
@onready var transition = $transition

var steps
var step = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	steps = [control, control_2, control_3]
	transition.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hovering and Input.is_action_just_released("select"):
		step += 1
	
	if step == 3:
		get_tree().change_scene_to_file('res://scene/phase_1_levelgenerator.tscn')
	
	for i in range(steps.size()):
		if step == i:
			steps[i].visible = true
		else:
			steps[i].visible = false


func _on_texture_rect_mouse_entered():
	hovering = true


func _on_texture_rect_mouse_exited():
	hovering = false
