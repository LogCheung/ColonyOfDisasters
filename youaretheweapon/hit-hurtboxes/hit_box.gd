extends Area2D

@export var damage = 5

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableHitBoxTimer

signal hit()

func tempdisable():
	collision.call_deferred("set","disabled",true)
	disableTimer.start()


func _on_disable_hit_box_timer_timeout():
	collision.call_deferred("set","disabled",false)


func _on_area_entered(area):
	if area.is_in_group("Player"):
		emit_signal("hit")
