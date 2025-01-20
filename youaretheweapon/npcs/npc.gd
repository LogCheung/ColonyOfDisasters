extends CharacterBody2D

var is_moving = false
var looking_for_wood = false
var _target

var distance_from_target

@export var hunger = Global.food
@export var wood = Global.wood
@export var energy = 100

@onready var treeTiles : TileMapLayer = get_parent().get_parent().get_child(0).get_child(0)
@onready var anim: AnimationPlayer = %AnimationPlayer


var treePosits : Array
var treesAround : int = treePosits.size()
var treeHits : int

func _process(delta: float) -> void:
	treePosits = treeTiles.get_used_cells() if treeTiles != null else [Vector2.ZERO]
	for cellIndex in range(treePosits.size()):
		treePosits[cellIndex] = Vector2i(treeTiles.map_to_local(treePosits[cellIndex]).x,treeTiles.map_to_local(treePosits[cellIndex]).y)
	treesAround = treePosits.size()
	
	_handle_target(delta)
	
	distance_from_target = global_position.distance_to(_target) if _target else 1000000
	
	wood = Global.wood

func _handle_target(delta: float):
	#if is_sleeping:
		#return
	if _target == null:
		_target = null
		# if it's still looking for food, try to find a new target
		if looking_for_wood:
			find_wood()
		return

	if self.global_position.distance_to(_target) <= 20:
		#$body.play("idle")
		if looking_for_wood and treePosits.has(_target):
			chopping_tree()
		else:
			looking_for_wood = false
			_target = null
		return
	
	move_to(self.global_position.direction_to(_target), delta)

func chopping_tree():
	var target_tile : TileData = treeTiles.get_cell_tile_data(treeTiles.local_to_map(_target))
	if not target_tile:
		return
	
	var target_health = target_tile.get_custom_data("Health")
	var target_reward = target_tile.get_custom_data("Wood")
	while treeHits < target_health and !anim.is_playing():
		chop()
	if treeHits == target_health:
		Global.wood = Global.wood + target_reward
		treeTiles.set_cell(treeTiles.local_to_map(_target),-1)
		treePosits.remove_at(treePosits.find(_target))
		treeHits = 0
		_target = null

func chop():
	anim.play("chop")
	treeHits = treeHits + 1

func move_to(direction, delta):
	is_moving = true
	if direction.x > 0:
		$Flip.scale.x = 1
		#turn right
	else:
		# turn left
		$Flip.scale.x = -1
	# warning-ignore:return_value_discarded
	velocity = direction * 1000 * delta
	move_and_slide()

func find_wood():
	var closest = _get_closest_wood()
	if closest != null:
		_target = closest

func _get_closest_wood():
	var closest = null
	var closest_distance = null
	for wood in treePosits:
		var dist = self.global_position.distance_to(wood)
		if closest_distance == null or closest_distance > dist:
			closest_distance = dist
			closest = wood

	return closest


func _on_utility_ai_agent_top_score_action_changed(top_action_id: Variant) -> void:
	print("Action changed: %s" % top_action_id)
	match top_action_id:
		"idle":
			looking_for_wood = false
			_target = null
		"find_wood":
			find_wood()
			looking_for_wood = true
