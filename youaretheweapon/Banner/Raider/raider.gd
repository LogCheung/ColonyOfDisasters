extends CharacterBody2D

@export var form_position : Marker2D
@export var speed : float = 40

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var anim: AnimationPlayer = $AnimationPlayer

var is_in_position : bool

var _target

func _process(delta: float) -> void:
	if _target == null:
		go_to_formation()
		return
	
	if self.global_position.distance_to(_target) <= 6:
		is_in_position = true
		_target = null
		return
	else:
		is_in_position = false
		go_to_formation()
		
	nav.target_position = _target
	
	move_to(self.global_position.direction_to(nav.get_next_path_position() ), delta)

func go_to_formation():
	if form_position == null:
		return
	_target = form_position.global_position

func move_to(direction, delta):
	if direction.x > 0:
		$Flip.scale.x = 1
		#turn right
	else:
		# turn left
		$Flip.scale.x = -1
	# warning-ignore:return_value_discarded
	var new_velocity = direction * speed
	
	if nav.avoidance_enabled:
		nav.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
		
	if velocity != Vector2.ZERO:
		anim.play("walk")
	else:
		anim.play("idle")
	move_and_slide()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
