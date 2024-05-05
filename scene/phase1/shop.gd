extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var new_message_timer = $newmessage
@onready var show_message_timer = $showmessage
@onready var rich_text_label = $RichTextLabel
@onready var uzi = $uzi
@onready var shotgun = $shotgun
@onready var sniper = $sniper
@onready var grenadelauncher = $grenadelauncher
@onready var rich_text_label_2 = $RichTextLabel2
@onready var money = $money

var dialog = ['Cheap and affordable!', 'Quality products!', 'Ammunition included!', 'Give me money!', 'What are you looking for?', 'Come again friend!', 'Take a look friend!', 'What are you looking for, friend?']
var random = RandomNumberGenerator.new()
var level = GlobalVariables.level
var item_hovering = {'uzi': false, 'shotgun': false, 'sniper': false, 'grenadelauncher': false}

var prices = {'uzi': 4, 'grenadelauncher': 5, 'shotgun': 6, 'sniper': 5}

# Called when the node enters the scene tree for the first time.
func _ready():
	if level > 0 and level <= 4:
		animated_sprite.play('1_4')
		Audio.play_music('shop1')
	elif level >= 5 and level <= 9:
		animated_sprite.play('5_13')
		Audio.play_music('shop1')
	elif level >= 10 and level <= 13:
		animated_sprite.play('14')
		Audio.play_music('shop2')
		
	rich_text_label.text = dialog[random.randi_range(0, dialog.size()-1)]
	show_message_timer.start()
	money.text = 'Wallet: ' + str(GlobalVariables.wallet)

func _process(delta):
	if item_hovering['uzi']:
		if Input.is_action_just_released('select'):
			if GlobalVariables.wallet >= prices['uzi']:
				GlobalVariables.wallet -= prices['uzi']
				money.text = 'Wallet: ' + str(GlobalVariables.wallet)
				Audio.play_sfx('boughtgun')
			else:
				Audio.play_sfx('notenoughmoney')
	elif item_hovering['shotgun']:
		if Input.is_action_just_released('select'):
			if GlobalVariables.wallet >= prices['shotgun']:
				GlobalVariables.wallet -= prices['shotgun']
				money.text = 'Wallet: ' + str(GlobalVariables.wallet)
				Audio.play_sfx('boughtgun')
			else:
				Audio.play_sfx('notenoughmoney')
	elif item_hovering['sniper']:
		if Input.is_action_just_released('select'):
			if GlobalVariables.wallet >= prices['sniper']:
				GlobalVariables.wallet -= prices['sniper']
				money.text = 'Wallet: ' + str(GlobalVariables.wallet)
				Audio.play_sfx('boughtgun')
			else:
				Audio.play_sfx('notenoughmoney')
	elif item_hovering['grenadelauncher']:
		if Input.is_action_just_released('select'):
			if GlobalVariables.wallet >= prices['grenadelauncher']:
				GlobalVariables.wallet -= prices['grenadelauncher']
				money.text = 'Wallet: ' + str(GlobalVariables.wallet)
				Audio.play_sfx('boughtgun')
			else:
				Audio.play_sfx('notenoughmoney')

func _on_newmessage_timeout():
	rich_text_label.text = dialog[random.randi_range(0, dialog.size()-1)]
	rich_text_label.modulate = Color(1, 1, 1, 1)
	rich_text_label.set_position(Vector2(331, 156))
	show_message_timer.start()
	
func _on_showmessage_timeout():
	animation_player.play("new_animation")
	new_message_timer.start()


func _on_uzi_mouse_entered():
	uzi.modulate = Color('#878684')
	item_hovering['uzi'] = true


func _on_uzi_mouse_exited():
	uzi.modulate = Color(1, 1, 1, 1)
	item_hovering['uzi'] = false


func _on_shotgun_mouse_entered():
	shotgun.modulate = Color('#878684')
	item_hovering['shotgun'] = true


func _on_shotgun_mouse_exited():
	shotgun.modulate = Color(1, 1, 1, 1)
	item_hovering['shotgun'] = false


func _on_sniper_mouse_entered():
	sniper.modulate = Color('#878684')
	item_hovering['sniper'] = true


func _on_sniper_mouse_exited():
	sniper.modulate = Color(1, 1, 1, 1)
	item_hovering['sniper'] = false


func _on_grenadelauncher_mouse_entered():
	grenadelauncher.modulate = Color('#878684')
	rich_text_label_2.modulate = Color('#878684')
	item_hovering['grenadelauncher'] = true


func _on_grenadelauncher_mouse_exited():
	grenadelauncher.modulate = Color(1, 1, 1, 1)
	rich_text_label_2.modulate = Color(1, 1, 1, 1)
	item_hovering['grenadelauncher'] = false


func _on_rich_text_label_2_mouse_entered():
	grenadelauncher.modulate = Color('#878684')
	rich_text_label_2.modulate = Color('#878684')
	item_hovering['grenadelauncher'] = true


func _on_rich_text_label_2_mouse_exited():
	grenadelauncher.modulate = Color(1, 1, 1, 1)
	rich_text_label_2.modulate = Color(1, 1, 1, 1)
	item_hovering['grenadelauncher'] = false
