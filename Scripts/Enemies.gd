extends Node2D

@onready var audioStreamPlayer = $AudioStreamPlayer2D
@onready var splatterSounds = [
	preload("res://Sounds/splatter/splatter_1.mp3"),
	preload("res://Sounds/splatter/splatter_2.mp3"),
	preload("res://Sounds/splatter/splatter_3.mp3"),
	preload("res://Sounds/splatter/splatter_4.mp3"),
	preload("res://Sounds/splatter/splatter_5.mp3")
]

func playDeathSound(from: Vector2) -> void:
	audioStreamPlayer.global_position = from
	audioStreamPlayer.set_stream(splatterSounds[randi_range(0, 4)])
	audioStreamPlayer.play()
