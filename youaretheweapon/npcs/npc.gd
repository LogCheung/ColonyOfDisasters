extends CharacterBody2D

var is_moving = false
var _target

var distance_from_target

@export var hunger = Global.food
@export var wood = Global.wood
@export var energy = 100

@export var job = Job.LABORER
enum Job {
	LABORER,
	FARMER
}

@onready var tileMap : TileMapLayer = get_parent().get_parent().get_child(0)
@onready var treeTiles : TileMapLayer = tileMap.get_child(0)
@onready var farmTiles : TileMapLayer = tileMap.get_child(4)
@onready var anim: AnimationPlayer = %AnimationPlayer
# Occupation
var is_laborer : bool
var is_farmer : bool

# Trees and Wood
var looking_for_wood = false
var treePosits : Array
var treesAround : int = treePosits.size()
var treeHits : int

# Farming
var looking_for_farm : bool = false
var planting_or_havesting : bool = true
var unseedTiles : Array
var grownTiles : Array
var plantHarvestTiles : int
var has_seeds : bool

func _process(delta: float) -> void:
	# Trees
	treePosits = treeTiles.get_used_cells() if treeTiles != null else [Vector2.ZERO]
	for cellIndex in range(treePosits.size()):
		treePosits[cellIndex] = Vector2i(treeTiles.map_to_local(treePosits[cellIndex]).x,treeTiles.map_to_local(treePosits[cellIndex]).y)
	treesAround = treePosits.size()
	
	# plants
	plantHarvestTiles = unseedTiles.size() + grownTiles.size()
	%NeedPlantHarvest.max_value = farmTiles.get_used_cells().size()
	print(unseedTiles.size())
	# handle
	_handle_target(delta)
	_handle_job()
	
	# distance
	distance_from_target = global_position.distance_to(_target) if _target else 1000000.0
	
	# global update
	has_seeds = true if Global.seeds > 0 else false
	wood = Global.wood

# Frame handling of target, occupation,
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------------------

func _handle_target(delta: float):
	#if is_sleeping:
		#return
	if _target == null:
		_target = null
		# if it's still looking for food, try to find a new target
		if looking_for_wood:
			find_wood()
		elif looking_for_farm:
			find_food()
			
		return
		
	if looking_for_wood:
		if self.global_position.distance_to(_target) <= 20:
			chopping_tree()
			return
	
	if looking_for_farm:
		if self.global_position.distance_to(_target) <= 1:
			plant_seed()
			return
	#if self.global_position.distance_to(_target) <= 10:
		##$body.play("idle")
		#if looking_for_wood and treePosits.has(_target):
			#chopping_tree()
		#elif looking_for_farm :
			#plant_seed()
			#
			#
	
	move_to(self.global_position.direction_to(_target), delta)

func _handle_job():
	match job:
		Job.LABORER:
			is_farmer = false
			is_laborer = true # current job
		Job.FARMER:
			is_farmer = true # current job
			is_laborer = false

# Woodcutting
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------------------

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
	for tree in treePosits:
		var dist = self.global_position.distance_to(tree)
		if closest_distance == null or closest_distance > dist:
			closest_distance = dist
			closest = tree
	return closest

# Farming
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------------------

func _get_closest_tile(posits : Array):
	var closest = null
	var closest_distance = null
	for pos in posits:
		var dist = self.global_position.distance_to(pos)
		if closest_distance == null or closest_distance > dist:
			closest_distance = dist
			closest = pos
			
	if closest != null:
		_target = closest
		

func find_food():
	unseedTiles = farmTiles.get_used_cells_by_id(1,Vector2(0,4))
	for cellIndex in range(unseedTiles.size()):
		unseedTiles[cellIndex] = Vector2i(farmTiles.map_to_local(unseedTiles[cellIndex]).x,farmTiles.map_to_local(unseedTiles[cellIndex]).y)
	
	grownTiles = farmTiles.get_used_cells_by_id(1,Vector2(4,4))
	for cellIndex in range(grownTiles.size()):
		grownTiles[cellIndex] = Vector2i(farmTiles.map_to_local(grownTiles[cellIndex]).x,farmTiles.map_to_local(grownTiles[cellIndex]).y)
	
	_get_closest_tile(unseedTiles) if Global.seeds > 0 and unseedTiles.size() > 0 else _get_closest_tile(grownTiles)

func plant_seed():
	var mapTarget : Vector2i = farmTiles.local_to_map(_target)
	if farmTiles.get_cell_atlas_coords(mapTarget) == Vector2i(4,4):
		harvest(mapTarget)
		return
	if Global.seeds <= 0:
		return
	
	var target_tile : TileData = farmTiles.get_cell_tile_data(farmTiles.local_to_map(_target))
	if not target_tile:
		return
		
	farmTiles.set_cell(mapTarget, 1,  Vector2i(farmTiles.get_cell_atlas_coords(mapTarget).x + 1,farmTiles.get_cell_atlas_coords(mapTarget).y ))
	unseedTiles = farmTiles.get_used_cells_by_id(1,Vector2(0,4))
	tileMap.seed_planted.emit(mapTarget)
	Global.seeds -= 1
	_target = null


func harvest(mapTarget : Vector2i):
	
	farmTiles.set_cell(mapTarget, 1,  Vector2i(0,4))
	grownTiles = farmTiles.get_used_cells_by_id(1,Vector2(4,4))
	Global.food += 2
	_target = null

# Utility AI action change
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------------------

func _on_utility_ai_agent_top_score_action_changed(top_action_id: Variant) -> void:
	print("Action changed: %s" % top_action_id)
	match top_action_id:
		"idle":
			looking_for_wood = clear_actions_and_set_current(false)
			_target = null
		"find_wood":
			looking_for_wood = clear_actions_and_set_current(true)
			find_wood()
		"farm_food":
			looking_for_farm = clear_actions_and_set_current(true)
			find_food()


func clear_actions_and_set_current(boolean : bool):
	looking_for_farm = false
	looking_for_wood = false
	_target = null
	
	return boolean
