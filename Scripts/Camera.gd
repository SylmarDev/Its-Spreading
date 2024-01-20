extends Camera2D

@onready var viewport_size = get_viewport().size

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var x = zoom.x * viewport_size.x/2
	var y = zoom.y * viewport_size.y/2
	
	position.x = clamp(position.x, limit_left+x, limit_right-x)
	position.y = clamp(position.y, limit_top+y, limit_bottom-y)
