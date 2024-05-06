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

var sfx_vol = GlobalVariables.sfx_volume
var rng = RandomNumberGenerator.new()

func _ready():
	phase1_music = [phase1_1, phase1_2]
	phase2_music = [phase2_1, phase2_2, phase2_3]

func play_sfx(sfx):
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = sfx_vol
	sfx_player.name = 'sfx_player'
	if sfx == 'boughtgun':
		sfx_player.stream = boughtgun
	elif sfx == 'breaktile':
		sfx_player.stream = breaktile
	elif sfx == 'notenoughmoney':
		sfx_player.stream = notenoughmoney
	elif sfx == 'button':
		sfx_player.stream = button

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
