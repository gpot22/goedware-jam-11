extends Control

@onready var masterslider = $masterslider
@onready var musicslider = $musicslider
@onready var sfxslider = $sfxslider
@onready var transition = $transition


# Called when the node enters the scene tree for the first time.
func _ready():
	transition.play("default")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_masterslider_value_changed(value):
	print(value)
	GlobalVariables.master_volume = value


func _on_musicslider_value_changed(value):
	print(value)
	GlobalVariables.music_volume = value


func _on_sfxslider_value_changed(value):
	print(value)
	GlobalVariables.sfx_volume = value
