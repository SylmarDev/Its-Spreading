extends Area2D

var speed = 400.0
var speedDecay = 1
var sprite
var sprite_width: float
var thingsIHit: Array

func _ready():
	set_as_top_level(true)
	sprite = $Sprite2D
	sprite_width = sprite.texture.get_width()
	
	#scale.x = max(1, speed / sprite_width)

func _physics_process(delta):
	position += (Vector2.RIGHT * speed).rotated(rotation) * delta
	speed = lerp(speed, 200.0, 0.01)

func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free() # disappears

func _on_body_entered(body):
	# always destroy on walls
	if (body.name == "Walls"):
		queue_free()
	
	if (body.name in thingsIHit):
		queue_free()
		# call a hurt function on the body
