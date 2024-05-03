extends 'res://scripts/EnemySuperclass.gd'


func _ready():
	health = 100
	vel = 0
	direction = -1
	state = 'idle'

func _physics_process(delta):
	apply_gravity(delta)
	
