extends Node2D
class_name Map

@onready var textPanel = $CanvasLayer/Panel
@onready var gameplayMusic = $GameplayMusic

func _ready():
	if global.currentStage != 0:
		textPanel.hide()
		
func _process(delta):
	if (!gameplayMusic.playing):
		gameplayMusic.playing = true

func _on_button_pressed():
	global.paused = false
	textPanel.hide()
