extends Node2D
class_name Map

@onready var textPanel = $CanvasLayer/Panel

func _ready():
	if global.currentStage != 0:
		textPanel.hide()

func _on_button_pressed():
	global.paused = false
	textPanel.hide()
