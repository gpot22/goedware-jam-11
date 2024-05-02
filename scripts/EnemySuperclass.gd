extends 'res://scripts/CharacterSuperclass.gd'

# BASE CONSTANTS
var rng = RandomNumberGenerator.new()

# ATTRIBUTES
var health
var vel
var direction
var state = 'idle'
var player = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
