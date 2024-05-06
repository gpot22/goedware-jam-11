extends AudioStreamPlayer

const title = preload("res://assets/music/title.mp3")
const phase1_1 = preload("res://assets/music/phase1_1.mp3")
const phase1_2 = preload("res://assets/music/phase1_2.mp3")
var phase1_music = []

const phase2_1 = preload("res://assets/music/phase2_1.mp3")
const phase2_2 = preload("res://assets/music/phase2_2.mp3")
const phase2_3 = preload("res://assets/music/phase2_3.mp3")
var phase2_music = []

const shop1 = preload("res://assets/music/shop1.mp3")
const shop2 = preload("res://assets/music/shop2.mp3")
const settings = preload("res://assets/music/settings.mp3")

const boughtgun = preload("res://assets/sfx/boughtgun.mp3")
const breaktile = preload("res://assets/sfx/breaktile.mp3")
const notenoughmoney = preload("res://assets/sfx/notenoughmoney.wav")
const button = preload("res://assets/sfx/button.mp3")

const dash = preload("res://assets/sfx/dash.mp3")
const footsteps = preload("res://assets/sfx/footsteps.mp3")
const grenadelauncher1 = preload("res://assets/sfx/grenadelauncher1.mp3")
const grenadelauncher2 = preload("res://assets/sfx/grenadelauncher2.mp3")
const grenadelauncher3 = preload("res://assets/sfx/grenadelauncher3.mp3")
const hit1 = preload("res://assets/sfx/hit1.mp3")
const hit2 = preload("res://assets/sfx/hit2.mp3")
const hit3 = preload("res://assets/sfx/hit3.mp3")
const jump = preload("res://assets/sfx/jump.mp3")
const explosion1 = preload("res://assets/sfx/explosion1.mp3")
const pistol_equip = preload("res://assets/sfx/pistol_equip.mp3")
const pistol1 = preload("res://assets/sfx/pistol1.mp3")
const pistol2 = preload("res://assets/sfx/pistol2.mp3")
const pistol3 = preload("res://assets/sfx/pistol3.mp3")
const sniper_plus = preload("res://assets/sfx/sniper_plus.mp3")
const sniper_enemy = preload("res://assets/sfx/sniper_enemy.mp3")
const sniper_player = preload("res://assets/sfx/sniper_player.mp3")
const sniper_equip = preload("res://assets/sfx/sniper_equip.mp3")
const uzi_equip = preload("res://assets/sfx/uzi_equip.mp3")
const uzi1 = preload("res://assets/sfx/uzi1.mp3")
const uzi2 = preload("res://assets/sfx/uzi2.mp3")
const uzi3 = preload("res://assets/sfx/uzi3.mp3")
const shotgun = preload("res://assets/sfx/shotgun.mp3")

var sfx_vol = linear_to_db(GlobalVariables.sfx_volume)
var rng = RandomNumberGenerator.new()

func _ready():
	phase1_music = [phase1_1, phase1_2]
	phase2_music = [phase2_1, phase2_2, phase2_3]

func play_sfx(sfx):
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = sfx_vol * 3
	sfx_player.name = 'sfx_player'
	if sfx == 'boughtgun':
		sfx_player.stream = boughtgun
	elif sfx == 'breaktile':
		sfx_player.stream = breaktile
	elif sfx == 'notenoughmoney':
		sfx_player.stream = notenoughmoney
	elif sfx == 'button':
		sfx_player.stream = button
	elif sfx == 'dash':
		sfx_player.stream = dash
	elif sfx == 'footsteps':
		sfx_player.stream = footsteps
	elif sfx == 'grenadelauncher1':
		sfx_player.stream = grenadelauncher1
	elif sfx == 'grenadelauncher2':
		sfx_player.stream = grenadelauncher2
	elif sfx == 'grenadelauncher3':
		sfx_player.stream = grenadelauncher3
	elif sfx == 'hit1':
		sfx_player.stream = hit1
	elif sfx == 'hit2':
		sfx_player.stream = hit2
	elif sfx == 'hit3':
		sfx_player.stream = hit3
	elif sfx == 'jump':
		sfx_player.stream = jump
	elif sfx == 'explosion1':
		sfx_player.stream = explosion1
	elif sfx == 'pistol_equip':
		sfx_player.stream = pistol_equip
	elif sfx == 'pistol1':
		sfx_player.stream = pistol1
	elif sfx == 'pistol2':
		sfx_player.stream = pistol2
	elif sfx == 'pistol3':
		sfx_player.stream = pistol3
	elif sfx == 'sniper_plus':
		sfx_player.stream = sniper_plus
	elif sfx == 'sniper_enemy':
		sfx_player.stream = sniper_enemy
	elif sfx == 'sniper_player':
		sfx_player.stream = sniper_player
	elif sfx == 'sniper_equip':
		sfx_player.stream = sniper_equip
	elif sfx == 'uzi_equip':
		sfx_player.stream = uzi_equip
	elif sfx == 'uzi1':
		sfx_player.stream = uzi1
	elif sfx == 'uzi2':
		sfx_player.stream = uzi2
	elif sfx == 'uzi3':
		sfx_player.stream = uzi3
	elif sfx == 'shotgun':
		sfx_player.stream = shotgun
	

	add_child(sfx_player)
	sfx_player.play()
	
	await sfx_player.finished
	sfx_player.queue_free()

func play_music(scene):
	if scene == 'title':
		if stream == title:
			return
		stream = title
		volume_db = linear_to_db(GlobalVariables.music_volume * GlobalVariables.master_volume)
		play()
	elif scene == 'settings':
		if stream == settings:
			return
		stream = settings
		volume_db = linear_to_db(GlobalVariables.music_volume * GlobalVariables.master_volume)
		play()
	elif scene == 'phase1_1':
		if stream == phase1_1:
			return
		stream = phase1_1
		volume_db = linear_to_db(GlobalVariables.music_volume * GlobalVariables.master_volume)
		play()
	elif scene == 'phase1_2':
		if stream == phase1_2:
			return
		stream = phase1_2
		volume_db = linear_to_db(GlobalVariables.music_volume * GlobalVariables.master_volume)
		play()
	elif scene == 'phase2_1':
		if stream == phase2_1:
			return
		stream = phase2_1
		volume_db = linear_to_db(GlobalVariables.music_volume * GlobalVariables.master_volume)
		play()
	elif scene == 'phase2_2':
		if stream == phase2_2:
			return
		stream = phase2_2
		volume_db = linear_to_db(GlobalVariables.music_volume * GlobalVariables.master_volume)
		play()
	elif scene == 'phase2_3':
		if stream == phase2_3:
			return
		stream = phase2_3
		volume_db = linear_to_db(GlobalVariables.music_volume * GlobalVariables.master_volume)
		play()
	elif scene == 'shop1':
		if stream == shop1:
			return
		stream = shop1
		volume_db = linear_to_db(GlobalVariables.music_volume * GlobalVariables.master_volume)
		play()
	elif scene == 'shop2':
		if stream == shop2:
			return
		stream = shop2
		volume_db = linear_to_db(GlobalVariables.music_volume * GlobalVariables.master_volume)
		play()


func change_master_volume():
	volume_db = linear_to_db(GlobalVariables.music_volume * GlobalVariables.master_volume)
	sfx_vol = linear_to_db(GlobalVariables.sfx_volume * GlobalVariables.master_volume)

func change_music_volume():
	volume_db = linear_to_db(GlobalVariables.music_volume * GlobalVariables.master_volume)
	
func change_sfx_volume():
	sfx_vol = linear_to_db(GlobalVariables.sfx_volume * GlobalVariables.master_volume)
