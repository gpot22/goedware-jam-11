extends AudioStreamPlayer

const title = preload("res://assets/music/title.mp3")
const phase1 = preload("res://assets/music/phase1.mp3")
const phase2 = preload("res://assets/music/phase2.mp3")
const shop1 = preload("res://assets/music/shop1.mp3")
const shop2 = preload("res://assets/music/shop2.mp3")

const boughtgun = preload("res://assets/sfx/boughtgun.mp3")
const breaktile = preload("res://assets/sfx/breaktile.mp3")
const notenoughmoney = preload("res://assets/sfx/notenoughmoney.wav")
const button = preload("res://assets/sfx/button.mp3")

var sfx_vol = GlobalVariables.sfx_volume

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
	if scene == 'settings':
		if stream == title:
			return
		stream = title
		volume_db = linear_to_db(GlobalVariables.music_volume * GlobalVariables.master_volume)
		play()
	elif scene == 'phase1':
		if stream == phase1:
			return
		stream = phase1
		volume_db = linear_to_db(GlobalVariables.music_volume * GlobalVariables.master_volume)
		play()
	elif scene == 'phase2':
		if stream == phase2:
			return
		stream = phase2
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