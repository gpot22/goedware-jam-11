extends Control
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var playbutton = $playbutton
@onready var settingsbutton = $settingsbutton
@onready var creditsbutton = $creditsbutton


# Called when the node enters the scene tree for the first time.
func _ready():
	animated_sprite_2d.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
