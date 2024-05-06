extends Marker2D

const ENEMY_DIR = 'res://scene/phase2/enemies'
const ENEMIES = {
	'beef': ENEMY_DIR + '/enemy_beef.tscn',
	'bombardier': ENEMY_DIR + '/enemy_bombardier.tscn',
	'sniper': ENEMY_DIR + '/enemy_sniper.tscn',
	'turret': ENEMY_DIR + '/turret.tscn'
}

var valid_enemies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for e in ENEMIES.keys():
		if name.contains(e):
			valid_enemies.append(e)


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
