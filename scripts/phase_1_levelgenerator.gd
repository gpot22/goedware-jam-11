extends Node2D

var phase_1 = preload("res://scene/phase1/phase_1.tscn")

#{'beef': [], 'bombardier': [], 'sniper': [], 'turret': []}
var level_1_enemies = {'beef': [[2, 3], [5, 3]], 'bombardier': [], 'sniper': [], 'turret': []}
var level_2_enemies = {'beef': [[2, 3]], 'bombardier': [[4, 2], [4, 5]], 'sniper': [], 'turret': []}
var level_3_enemies = {'beef': [[2, 5]], 'bombardier': [], 'sniper': [[2, 4], [5, 2]], 'turret': []}
var level_4_enemies = {'beef': [], 'bombardier': [[6, 4]], 'sniper': [[1, 4]], 'turret': [[2, 3], [5, 3]]}
var level_5_enemies = {'beef': [[2, 5], [3, 5], [4, 5], [6, 3]], 'bombardier': [[1, 2], [2, 1]], 'sniper': [[6, 2]], 'turret': [[1, 1], [3, 6]]}

var level_6_enemies = {'beef': [], 'bombardier': [], 'sniper': [], 'turret': []}
var level_7_enemies = {'beef': [], 'bombardier': [], 'sniper': [], 'turret': []}
var level_8_enemies = {'beef': [], 'bombardier': [], 'sniper': [], 'turret': []}
var level_9_enemies = {'beef': [], 'bombardier': [], 'sniper': [], 'turret': []}
var level_10_enemies = {'beef': [], 'bombardier': [], 'sniper': [], 'turret': []}
var level_11_enemies = {'beef': [], 'bombardier': [], 'sniper': [], 'turret': []}
var level_12_enemies = {'beef': [], 'bombardier': [], 'sniper': [], 'turret': []}
var level_13_enemies = {'beef': [], 'bombardier': [], 'sniper': [], 'turret': []}
var level_14_enemies = {'beef': [], 'bombardier': [], 'sniper': [], 'turret': []}
var level_15_enemies = {'beef': [], 'bombardier': [], 'sniper': [], 'turret': []}

var current_level = 0
var level_enemies = [level_1_enemies, level_2_enemies, level_3_enemies, level_4_enemies, level_5_enemies, level_6_enemies, level_7_enemies, level_8_enemies, level_9_enemies, level_10_enemies, level_11_enemies, level_12_enemies, level_13_enemies, level_14_enemies, level_15_enemies]

# Called when the node enters the scene tree for the first time.
func _ready():
	#generate_premade_levels()
	var a = phase_1.instantiate()
	a.tiles_with_enemies = level_enemies[current_level]
	add_child(a)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("nextlevel"):
		if current_level == level_enemies.size()-1:
			return
		get_child(0).queue_free()
		var a = phase_1.instantiate()
		current_level += 1
		a.tiles_with_enemies = level_enemies[current_level]
		add_child(a)
	elif Input.is_action_just_pressed("previouslevel"):
		if current_level == 0:
			return
		get_child(0).queue_free()
		var a = phase_1.instantiate()
		current_level -= 1
		a.tiles_with_enemies = level_enemies[current_level]
		add_child(a)