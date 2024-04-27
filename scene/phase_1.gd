extends Node2D
@onready var camera_2d = $Camera2D
@onready var texture_rect = $TextureRect

var viewport_width = 800.0
var viewport_height = 450.0
var camera_state = 'in'
var cam_pos_x = viewport_width/2
var cam_pos_y = viewport_height/2
var previous_cam_pos_x = 0
var previous_cam_pos_y = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_camera()

func handle_camera():
	# default viewport = 800x450
	if Input.is_action_just_pressed("swapcamera"):
		if camera_state == 'in':
			previous_cam_pos_x = cam_pos_x
			previous_cam_pos_y = cam_pos_y
			cam_pos_x = texture_rect.texture.get_width()/2
			cam_pos_y = texture_rect.texture.get_height()/2
			camera_2d.zoom = Vector2(viewport_width/texture_rect.texture.get_width(), viewport_height/texture_rect.texture.get_height())
			camera_state = 'out'
		else:
			cam_pos_x = previous_cam_pos_x
			cam_pos_y = previous_cam_pos_y
			camera_2d.zoom = Vector2(1, 1)
			camera_state = 'in'
		camera_2d.set_position(Vector2(cam_pos_x, cam_pos_y))
	var directionLR = Input.get_axis('panleft', 'panright')
	var directionUD = Input.get_axis('panup', 'pandown')
	if camera_state == 'in':
		if directionLR == 1:
			if cam_pos_x + viewport_width/2 + 3 <= texture_rect.texture.get_width():
				cam_pos_x += 3
		if directionLR == -1:
			if cam_pos_x - viewport_width/2 - 3 >= 0:
				cam_pos_x -= 3
		if directionUD == 1:
			if cam_pos_y + viewport_height/2 + 3 <= texture_rect.texture.get_height():
				cam_pos_y += 3
		if directionUD == -1:
			if cam_pos_y - viewport_height/2 - 3 >= 0:
				cam_pos_y -= 3
		
		if directionLR != 0 or directionUD != 0:
			camera_2d.set_position(Vector2(cam_pos_x, cam_pos_y))
