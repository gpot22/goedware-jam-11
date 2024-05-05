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
@onready var money = $money

var dialog = ['Cheap and affordable!', 'Quality products!', 'Ammunition included!', 'Give me money!', 'What are you looking for?', 'Come again friend!', 'Take a look friend!', 'What are you looking for, friend?']
var random = RandomNumberGenerator.new()
var level = GlobalVariables.level
var item_hovering = {'uzi': false, 'shotgun': false, 'sniper': false, 'grenadelauncher': false}

# Called when the node enters the scene tree for the first time.
func _ready():
	if level > 0 and level < 5:
		animated_sprite.play('1_4')
	elif level > 4 and level < 14:
		animated_sprite.play('5_13')
	elif level == 14:
		animated_sprite.play('14')
		
	rich_text_label.text = dialog[random.randi_range(0, dialog.size()-1)]
	show_message_timer.start()
	money.text = 'Wallet: ' + str(GlobalVariables.wallet)

func _process(delta):
	if item_hovering['uzi']:
		pass
	elif item_hovering['shotgun']:
		pass
	elif item_hovering['sniper']:
		pass
	elif item_hovering['grenadelauncher']:
		pass

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
	item_hovering['grenadelauncher'] = true


func _on_grenadelauncher_mouse_exited():
	grenadelauncher.modulate = Color(1, 1, 1, 1)
	item_hovering['grenadelauncher'] = false
