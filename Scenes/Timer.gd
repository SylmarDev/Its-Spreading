extends Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_stopped():
		get_node("../../Player/PointLight2D").energy = time_left / 2
		var val = time_left / 2
		get_node("../../CanvasModulate").color = Color(val, val, val)
		get_node("../../CanvasLayer").hide()
