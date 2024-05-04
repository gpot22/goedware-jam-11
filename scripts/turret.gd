extends StaticBody2D

# ATTRIBUTES
var health
var state = 'idle'
var player = null

# STUFF
@onready var base = $body/base
@onready var head = $body/head

func _physics_process(delta):
	if state == 'idle':
		return
	
	if state == 'hostile':
		print('hostile')

func update_animations():
	if state == 'idle':
		head.play('idle')
		base.play('idle')

func charge_up():
	#var t = 0.2
	base.play('charge1')
	await base.animation_finished
	base.play('charge2')
	await base.animation_finished
	base.play('charge3')
	await base.animation_finished
	base.play('charge4')
	await base.animation_finished
	return true
	

func _on_shooting_area_body_entered(body):
	if body.name != 'Player': return	
	player = body
	state = 'hostile'


func _on_shooting_area_body_exited(body):
	if body.name != 'Player': return	
	player = body
	state = 'idle'
