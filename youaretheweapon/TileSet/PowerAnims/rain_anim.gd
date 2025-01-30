extends AnimatedSprite2D

@export var power : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match power:
		1: 
			z_index = 30
			play("rain")
		2:
			z_index = 30
			play("wind")
		3:
			z_index = 1
			play("quake")
func _on_animation_finished() -> void:
	queue_free()
