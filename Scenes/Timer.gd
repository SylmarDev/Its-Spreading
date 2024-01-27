extends Timer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_stopped():
		var val = time_left / 2
		get_node("../../GameplayMusic").volume_db -= 0.25
		get_node("../../Player/PointLight2D").energy = val
		get_node("../../CanvasModulate").color = Color(val, val, val)
		get_node("../../CanvasLayer").hide()
