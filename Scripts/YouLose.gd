extends Node2D

@onready var trashTalk = $TrashTalk
var createdAt
var waitBeforeAcceptingInput = 1000
var clicked = false;

var helpfulMessages = [
	"Watch out for the rot. Its spreading",
	"Its spreading btw",
	"The shamblers do damage",
	"Skill Issue",
	"Its okay, mistakes happen",
	"Well it wasn't a great attempt anyways",
	"That's rough buddy"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	trashTalk.text = helpfulMessages[randi() % helpfulMessages.size()]
	
func create():
	createdAt = Time.get_ticks_msec()
	
func _process(delta):
	if createdAt != null and Time.get_ticks_msec() - createdAt > waitBeforeAcceptingInput:
		$PressAny.show()

func _input(event):
	if !clicked and visible and Time.get_ticks_msec() - createdAt > waitBeforeAcceptingInput and event is InputEventKey:
		get_node("../../RotMap/Timer").start()
		clicked = true


func _on_timer_timeout():
	if clicked:
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
		
