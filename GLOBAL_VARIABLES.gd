extends Node

var level = 1
var discovered_enemies = []
var wallet = 20
var master_volume = 0.5
var music_volume = 0.5
var sfx_volume = 0.5
var unlocked_weapons = ['pistol']
var phase_2_enemy_count = {'beef': 0, 'bombardier': 0, 'sniper': 0, 'turret': 0}
var phase_2_enemy_locations = {'beef': [], 'bombardier': [], 'sniper': [], 'turret': []}
var phase_2_corners = []
var stage_size = ''
var equipped_weapons = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
