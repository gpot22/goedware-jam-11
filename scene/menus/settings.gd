extends Control

@onready var masterslider = $masterslider
@onready var musicslider = $musicslider
@onready var sfxslider = $sfxslider
@onready var transition = $transition


# Called when the node enters the scene tree for the first time.
func _ready():
	masterslider.max_value = 1
	masterslider.step = 0.0001
	masterslider.value = GlobalVariables.master_volume
	sfxslider.max_value = 1
	sfxslider.step = 0.0001
	sfxslider.value = GlobalVariables.sfx_volume
	musicslider.max_value = 1
	musicslider.step = 0.0001
	musicslider.value = GlobalVariables.music_volume
	Audio.play_music('settings')
	transition.play("default")


func _on_masterslider_value_changed(value):
	GlobalVariables.master_volume = value
	Audio.change_master_volume()

func _on_musicslider_value_changed(value):
	GlobalVariables.music_volume = value
	Audio.change_music_volume()

func _on_sfxslider_value_changed(value):
	GlobalVariables.sfx_volume = value
	Audio.change_sfx_volume()
