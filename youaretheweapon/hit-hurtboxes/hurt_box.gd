extends Area2D

var POP = preload("res://hit-hurtboxes/pop.tscn")

@export_enum("Cooldown","HitOnce","DisableHitBox") var HurtBoxType = 0

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer


signal hurt(damage)

func _on_area_entered(area):
	if area.is_in_group("attack"):
		if not area.get("damage") == null:
			match HurtBoxType:
				0: #Cooldown
					collision.call_deferred("set","disabled",true)
					disableTimer.start()
				1: #HitOnce
					pass
				2: #DisableHitBox
					if area.has_method("tempdisable"):
						area.tempdisable()
			var damage = area.damage
			emit_signal("hurt",damage)
			var pop = POP.instantiate()
			add_child(pop)
			pop.show_value(damage,false)



func _on_disable_timer_timeout():
	collision.call_deferred("set","disabled",false)
