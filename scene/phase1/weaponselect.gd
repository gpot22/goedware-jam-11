extends Node2D

@onready var sniper = $sniper
@onready var shotgun = $shotgun
@onready var pistol = $pistol
@onready var grenadelauncher = $grenadelauncher
@onready var uzi = $uzi
@onready var start = $start


var uphovering = false
var downhovering = false
var starthovering = false

var cycle_weapon_list = ['pistol', 'uzi', 'grenadelauncher']
var cycle_list
var cycle_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	cycle_list = [pistol, uzi, grenadelauncher]
	
	if cycle_weapon_list[cycle_index] not in GlobalVariables.unlocked_weapons:
		cycle_list[cycle_index].modulate = Color(0, 0, 0, 1)
	else:
		cycle_list[cycle_index].modulate = Color(1, 1, 1, 1)
	for i in range(cycle_list.size()):
		if i == cycle_index:
			cycle_list[i].visible = true
		else:
			cycle_list[i].visible = false
			
	if 'shotgun' in GlobalVariables.unlocked_weapons:
		shotgun.modulate = Color(1, 1, 1, 1)
	else:
		shotgun.modulate = Color(0, 0, 0, 1)
	if 'sniper' in GlobalVariables.unlocked_weapons:
		sniper.modulate = Color(1, 1, 1, 1)
	else:
		sniper.modulate = Color(0, 0, 0, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if starthovering:
		if Input.is_action_just_released('select'):
			if cycle_weapon_list[cycle_index] not in GlobalVariables.unlocked_weapons:
				return
			if 'shotgun' in GlobalVariables.unlocked_weapons:
				GlobalVariables.equipped_weapons.append('shotgun')
			if 'sniper' in GlobalVariables.unlocked_weapons:
				GlobalVariables.equipped_weapons.append('sniper')
			GlobalVariables.equipped_weapons.append(cycle_weapon_list[cycle_index])
			Audio.play_sfx('button')
			get_parent().go_to_phase_2()
	
	if uphovering:
		if Input.is_action_just_released('select'):
			Audio.play_sfx('button')
			if cycle_index == 2:
				cycle_index = 0
			else:
				cycle_index += 1
			if cycle_weapon_list[cycle_index] not in GlobalVariables.unlocked_weapons:
				cycle_list[cycle_index].modulate = Color(0, 0, 0, 1)
			else:
				cycle_list[cycle_index].modulate = Color(1, 1, 1, 1)
			for i in range(cycle_list.size()):
				if i == cycle_index:
					cycle_list[i].visible = true
				else:
					cycle_list[i].visible = false
	
	if downhovering:
		if Input.is_action_just_released('select'):
			Audio.play_sfx('button')
			if cycle_index == 0:
				cycle_index = 2
			else:
				cycle_index -= 1
			if cycle_weapon_list[cycle_index] not in GlobalVariables.unlocked_weapons:
				cycle_list[cycle_index].modulate = Color(0, 0, 0, 1)
			else:
				cycle_list[cycle_index].modulate = Color(1, 1, 1, 1)
			for i in range(cycle_list.size()):
				if i == cycle_index:
					cycle_list[i].visible = true
				else:
					cycle_list[i].visible = false


func _on_uparrow_1_mouse_entered():
	uphovering = true


func _on_uparrow_1_mouse_exited():
	uphovering = false


func _on_downarrow_1_mouse_entered():
	downhovering = true


func _on_downarrow_1_mouse_exited():
	downhovering = false


func _on_start_mouse_entered():
	start.modulate = Color('#aeaeae')
	starthovering = true


func _on_start_mouse_exited():
	start.modulate = Color('#ffffff')
	starthovering = false
