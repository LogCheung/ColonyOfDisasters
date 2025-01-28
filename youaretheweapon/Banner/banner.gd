extends CharacterBody2D

# ALL COMBAT BETWEEN RAIDERS AND VILLAGERS ARE IN THIS SCRIPT
# WITH EXCEPTIONS TO RAIDER FORMATION AND MOVEMENT

var ROW : PackedScene = preload("res://Banner/row.tscn")

@export var from_distance : int = 6

@onready var floors: VBoxContainer = %Floors
@onready var row: HBoxContainer = %Row
@onready var row_size = row.get_child_count()
@onready var soldiers : Array = get_tree().get_nodes_in_group("ADULT")
@onready var positions : Array = get_tree().get_nodes_in_group("ALLYMARKER")
@onready var nav: NavigationAgent2D = $NavigationAgent2D

var enemy_banner 
var strength : int
var speed : float = 400.00
var _target 
var initial_form : bool = true
var player_bias = 1

func _ready() -> void:
	for unit in soldiers:
		unit.nav.avoidance_enabled = false
		unit.is_in_combat = true
	make_formation()
	_target = global_position

func _process(delta: float) -> void:
	Global.hour = 0
	if Input.is_action_just_pressed("loctest"):
		_target = get_global_mouse_position()
	
	handle_target(delta)
	
	positions = get_tree().get_nodes_in_group("ALLYMARKER")
	soldiers = get_tree().get_nodes_in_group("ADULT")
	
	strength = soldiers.size()
	
	if strength <= 0:
		back_to_peace()
	
	%AllyPower.rotation = -rotation
		#print("lol " + str(ally_power.global_position))

func handle_target(delta):
	nav.target_desired_distance = from_distance / 2
	nav.path_desired_distance = from_distance
	enemy_banner = get_tree().get_first_node_in_group("ENEMYBANNER")
	
	if enemy_banner != null:
		_target = enemy_banner.global_position
		self.look_at(_target)
	
	for unit in soldiers:
		if !initial_form:
			break
		if unit.is_in_position == false:
			return
	initial_form = false
	%AllyPower.visible = true
	%AllyPower.get_child(1).text = str(strength)
	
	if self.global_position.distance_to(_target) < from_distance:
		if strength > 0 or enemy_banner.strength > 0:
			if $Timer.time_left <= 0:
				$Timer.start()
		return
	
	nav.target_position = _target
	move_to(self.global_position.direction_to(nav.get_next_path_position() ), delta)
	pass
func make_formation():
	for i in range(soldiers.size() / 5):
		var new_row = ROW.instantiate()
		floors.add_child(new_row)
	positions = get_tree().get_nodes_in_group("ALLYMARKER")
	soldiers = get_tree().get_nodes_in_group("ADULT")
	for i in range(soldiers.size()):
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

func _on_timer_timeout() -> void:
	if !is_instance_valid(enemy_banner):
		back_to_peace()
		return
	if enemy_banner.strength <= 0:
		enemy_banner.queue_free()
		return
	var roll_range = strength + player_bias + enemy_banner.strength + 10
	player_bias = 1
	var rand = randi() % roll_range
	print(rand)
	if rand < strength + player_bias:
		get_tree().get_first_node_in_group("ENEMY").queue_free()
	elif rand < strength + enemy_banner.strength + player_bias:
		get_tree().get_first_node_in_group("ADULT").clear_roles()
		get_tree().get_first_node_in_group("ADULT").queue_free()
	elif rand < roll_range:
		pass

func back_to_peace() -> void:
	for i in range(soldiers.size()):
		#if soldiers[i].form_position != null:
			#continue
		soldiers[i].form_position = null
		soldiers[i].speed = 40
		soldiers[i].is_in_combat = false
	queue_free()
