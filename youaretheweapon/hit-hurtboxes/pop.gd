extends Label

var travel: Vector2 = Vector2(0, -20)
var duration: float = .65
var speed: float = PI / 3


func show_value(value: int, crit: bool):
	scale = Vector2(.75,.75)
	var tween = create_tween()
	text = str(value)
	pivot_offset = size / 6
	var movement = travel.rotated(randi_range(-speed / 2, speed / 2))
	
	#Aniamte In
	tween.tween_property(self, "position", position + movement, duration)
	
	#Fade Out
	tween.tween_property(self, "modulate:a", 0.0, duration)
	
	#if crit == true:
		#modulate = Color(1, 0, 0)
		#scale = scale * 2
		#tween.tween_property(self, "scale", scale, 0.4)
	
	tween.play()
	tween.tween_callback(queue_free)
