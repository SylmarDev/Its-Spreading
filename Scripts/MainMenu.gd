extends Control

@onready var titleTheme = $TitleTheme


# Called when the node enters the scene tree for the first time.
func _ready():
	global.setDefaults()
	$VBoxContainer/Start.grab_focus()
	
func _process(delta):
	if (!titleTheme.playing):
		titleTheme.playing = true

func _on_start_button_up():
	get_tree().change_scene_to_file("res://Scenes/Map.tscn")


func _on_exit_button_up():
	get_tree().quit()
