extends Area2D

const VEL = 1600
const RANGE = 1200
var travelled_distance = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * VEL * delta
	
	travelled_distance += VEL * delta
	if travelled_distance > RANGE:
		queue_free()
	#var collision = move_and_collide(vel)
	#if collision:  #handle bullet collisions
		#if collision.get_collider().name == "Enemy":
			#collision.get_collider().take_damage()
		## delete bullet
		#queue_free()
		

func _on_body_entered(body):
	if body.name == "Player": return
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()
