extends Node2D

var phase_1 = preload("res://scene/phase1/phase_1.tscn")
@onready var transition = $transition

#{'beef': [], 'bombardier': [], 'sniper': [], 'turret': [], 'slices': 0}
var level_1_enemies = {'beef': [[2, 3], [5, 3]], 'bombardier': [], 'sniper': [], 'turret': [], 'slices': 1}
var level_2_enemies = {'beef': [[2, 3]], 'bombardier': [[4, 2], [4, 5]], 'sniper': [], 'turret': [], 'slices': 2}
var level_3_enemies = {'beef': [[2, 5]], 'bombardier': [], 'sniper': [[2, 4], [5, 2]], 'turret': [], 'slices': 1}
var level_4_enemies = {'beef': [[1,0],[0,5],[2,2],[7,5]], 'bombardier': [[7,0],[5,2]], 'sniper': [[0,0],[0,4],[1,2],[1,5],[6,2],[6,5],[7,4]], 'turret': [], 'slices': 3}
var level_5_enemies = {'beef': [[2, 5], [3, 5], [4, 5], [6, 3]], 'bombardier': [[1, 2], [2, 1]], 'sniper': [[6, 2]], 'turret': [[1, 1], [3, 6]], 'slices': 1}
var level_6_enemies = {'beef': [[1,3],[2,3],[2,4],[5,3],[6,3],[5,4]], 'bombardier': [[7,5]], 'sniper': [[0,5]], 'turret': [[3,0],[4,0]], 'slices': 1}
var level_7_enemies = {'beef': [[2,3],[2,4],[5,3],[5,4],[6,6],[7,7]], 'bombardier': [[0,0],[1,0],[0,1],[3,3],[3,4],[4,4],[4,3]], 'sniper': [], 'turret': [[7,6],[6,7]], 'slices': 1}
var level_8_enemies = {'beef': [[0,0],[1,0],[0,1],[2,1],[2,2],[1,2],[6,5]], 'bombardier': [[0,2],[1,1],[2,0]], 'sniper': [[0,4],[0,5],[1,5]], 'turret': [[5,5],[6,4]], 'slices': 2}
var level_9_enemies = {'beef': [[2,3],[3,2],[4,2],[5,3],[1,6],[6,6]], 'bombardier': [[0,7],[7,7]], 'sniper': [[3,3],[4,3]], 'turret': [[0,0],[7,0]], 'slices': 1}
var level_10_enemies = {'beef': [[1,0], [0,1], [2,1], [1, 2], [6,5], [6,7], [5,6], [7,6]], 'bombardier': [[0,2], [7,5], [6,6]], 'sniper': [[2,0], [6,1],[1,6],[5,7]], 'turret': [[7,0],[0,7]], 'slices': 3}
var level_11_enemies = {'beef': [[0,0],[1,1],[6,6],[7,7]], 'bombardier': [[7,4],[7,6]], 'sniper': [[0,1],[0,3],[3,3],[4,3],[4,3],[4,4]], 'turret': [[1,0],[6,7]], 'slices': 3}
var level_12_enemies = {'beef': [[0,3],[0,4],[1,4],[3,6],[4,6],[3,7],[4,7],[6,4],[7,4],[7,3]], 'bombardier': [[0,2],[1,3],[0,5]], 'sniper': [[6,3],[7,2],[7,5]], 'turret': [[0,0],[1,0],[6,0],[7,0]], 'slices': 2}
var level_13_enemies = {'beef': [[0,0],[1,0],[2,0],[5,0],[6,0],[7,0],[0,7],[1,7],[2,7],[5,7],[6,7],[7,7]], 'bombardier': [[7,1],[2,3],[0,6],[5,4]], 'sniper': [[0,1],[7,6]], 'turret': [[1,1],[1,2],[6,1],[6,2],[1,5],[1,6],[6,5],[6,6]], 'slices': 2}

var current_level = GlobalVariables.level - 1
var level_enemies = [level_1_enemies, level_2_enemies, level_3_enemies, level_4_enemies, level_5_enemies, level_6_enemies, level_7_enemies, level_8_enemies, level_9_enemies, level_10_enemies, level_11_enemies, level_12_enemies, level_13_enemies]

# Called when the node enters the scene tree for the first time.
func _ready():
	transition.play("default")
	Audio.play_music('phase1')
	var a = phase_1.instantiate()
	a.tiles_with_enemies = level_enemies[current_level]
	a.total_isolations = level_enemies[current_level]['slices']
	a.remaining_isolations = level_enemies[current_level]['slices']
	a.level = current_level+1
	GlobalVariables.level = current_level+1
	add_child(a)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("nextlevel"):
		if current_level == level_enemies.size()-1:
			return
		get_child(1).queue_free()
		var a = phase_1.instantiate()
		current_level += 1
		a.tiles_with_enemies = level_enemies[current_level]
		a.total_isolations = level_enemies[current_level]['slices']
		a.remaining_isolations = level_enemies[current_level]['slices']
		a.level = current_level+1
		GlobalVariables.level = current_level+1
		add_child(a)
	elif Input.is_action_just_pressed("previouslevel"):
		if current_level == 0:
			return
		get_child(1).queue_free()
		var a = phase_1.instantiate()
		current_level -= 1
		a.tiles_with_enemies = level_enemies[current_level]
		a.total_isolations = level_enemies[current_level]['slices']
		a.remaining_isolations = level_enemies[current_level]['slices']
		a.level = current_level+1
		GlobalVariables.level = current_level+1
		add_child(a)
