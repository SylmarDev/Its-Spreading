extends Node2D

var createdAt
var waitBeforeAcceptingInput = 1000
var clicked = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Message" + str((randi() % 7) + 1)).show()
	
func create():
	createdAt = Time.get_ticks_msec()
	
func _process(delta):
	if createdAt != null and Time.get_ticks_msec() - createdAt > waitBeforeAcceptingInput:
		$TextureButton.show()

func _on_timer_timeout():
	if clicked:
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_texture_button_pressed():
	if visible and Time.get_ticks_msec() - createdAt > waitBeforeAcceptingInput:
		get_node("../../RotMap/Timer").start()
		clicked = true
