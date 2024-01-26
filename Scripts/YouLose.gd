extends Node2D

@onready var trashTalk = $TrashTalk
var createdAt = Time.get_ticks_msec()
var waitBeforeAcceptingInput = 2000

var helpfulMessages = [
	"Watch out for the rot. Its spreading",
	"Its spreading btw",
	"The shamblers do damage",
	"Skill Issue",
	"Its okay, mistakes happen",
	"Well, it wasn't a great attempt anyways",
	"That's rough buddy",
	"Almost!"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	trashTalk.text = helpfulMessages[randi() % helpfulMessages.size()]

func _input(event):
	if Time.get_ticks_msec() - createdAt > waitBeforeAcceptingInput and event is InputEventKey:
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
