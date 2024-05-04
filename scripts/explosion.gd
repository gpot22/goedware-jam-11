extends 'res://scripts/effect.gd'

func _ready():
	var rng = RandomNumberGenerator.new()
	var state = 'explosion' + str(rng.randi_range(0, 1))
	super._ready()
