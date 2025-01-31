extends AnimatedSprite2D

@export var type : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match type:
		1:  # Oak
			z_index = 30
			play("rain")
		2:  # Pine
			z_index = 30
			play("wind")

func _on_animation_finished() -> void:
	queue_free()
