extends Node2D

@onready var player = get_parent().get_node("Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (player != null and !global.paused):
		position = player.position
