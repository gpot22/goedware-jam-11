extends 'res://scripts/effect.gd'

var rng = RandomNumberGenerator.new()
func _ready():
	state = 'explosion' + str(rng.randi_range(0, 1))
	super._ready()
