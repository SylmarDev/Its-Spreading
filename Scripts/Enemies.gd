extends Node2D

@onready var audioStreamPlayer = $AudioStreamPlayer2D
@onready var splatterSounds = [
	preload("res://Sounds/splatter/splatter_1.mp3"),
	preload("res://Sounds/splatter/splatter_2.mp3"),
	preload("res://Sounds/splatter/splatter_3.mp3"),
	preload("res://Sounds/splatter/splatter_4.mp3"),
	preload("res://Sounds/splatter/splatter_5.mp3")
]

@onready var deathParticle = preload("res://Scenes/EnemyDeath.tscn")

func playDeathSound(from: Vector2) -> void:
	audioStreamPlayer.global_position = from
	audioStreamPlayer.set_stream(splatterSounds[randi_range(0, 4)])
	audioStreamPlayer.play()

func createDeathParticleEffect(pos: Vector2) -> void:
	var _particle = deathParticle.instantiate()
	_particle.position = pos
	_particle.emitting = true
	
	add_child(_particle)
