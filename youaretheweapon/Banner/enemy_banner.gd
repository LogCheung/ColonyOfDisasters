extends CharacterBody2D

var ROW : PackedScene = preload("res://Banner/enemy_row.tscn")

@export var from_distance : int = 6

@onready var floors: VBoxContainer = %Floors
@onready var row: HBoxContainer = %EnemyRow
@onready var row_size = row.get_child_count()
@onready var soldiers : Array = get_tree().get_nodes_in_group("ENEMY")
@onready var positions : Array = get_tree().get_nodes_in_group("ENEMYMARKER")
@onready var nav: NavigationAgent2D = $NavigationAgent2D

var speed : float = 800.00
var _target 
var strength : int
var initial_form : bool = true

func _ready() -> void:
	for unit in soldiers:
		if unit.nav == null:
			continue
		unit.nav.avoidance_enabled = false
	make_formation()
	_target = global_position

func _process(delta: float) -> void:
	%EnemyPower.rotation = -rotation
	
	if Input.is_action_just_pressed("loctest"):
		_target = get_global_mouse_position()
	
	handle_target(delta)
	
	positions = get_tree().get_nodes_in_group("ENEMYMARKER")
	soldiers = get_tree().get_nodes_in_group("ENEMY")
	
	strength = soldiers.size()
	
func handle_target(delta):
	nav.target_desired_distance = from_distance / 2
	nav.path_desired_distance = from_distance
	var enemy_banner = get_tree().get_first_node_in_group("ALLYBANNER")
	
	if enemy_banner == null and !initial_form:
		Global.food -= 5
		Global.wood -= 5
		Global.tools -= 3
		for unit in soldiers:
			unit.queue_free()
		queue_free()
	
	if enemy_banner != null:
		_target = enemy_banner.global_position
		self.look_at(_target)
	
	for unit in soldiers:
		if !is_instance_valid(unit):
			continue
		if !initial_form:
			break
		if unit.is_in_position == false:
			return
	initial_form = false
	%EnemyPower.visible = true
	%EnemyPower.get_child(1).text = str(strength)
	if self.global_position.distance_to(_target) < from_distance:
		for unit in soldiers:
			if !is_instance_valid(unit):
				continue
			unit.anim.play("attack")
		return
	
	nav.target_position = _target
	move_to(self.global_position.direction_to(nav.get_next_path_position() ), delta)
func make_formation():
	await get_tree().create_timer(.2).timeout
	for i in range(soldiers.size() / 5):
		var new_row = ROW.instantiate()
		floors.add_child(new_row)
	positions = get_tree().get_nodes_in_group("ENEMYMARKER")
	soldiers = get_tree().get_nodes_in_group("ENEMY")
	print(soldiers)
	for i in range(soldiers.size()):
		strength += 2
		#if soldiers[i].form_position != null:
			#continue
		soldiers[i].form_position = positions[i]
		soldiers[i].speed = 30
		await get_tree().create_timer(.1).timeout
		if soldiers[i]._target == null:
			continue
		var pos = positions[i].get_parent().get_child(1)
		pos.global_position = soldiers[i]._target
	strength = soldiers.size()
	pass

func move_to(direction, delta):
	#is_moving = true
	# warning-ignore:return_value_discarded
	velocity = direction * speed * delta
	move_and_slide()
