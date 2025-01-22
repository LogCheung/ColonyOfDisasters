extends CharacterBody2D

var is_moving = false
var _target

var distance_from_target

@export var hunger = Global.food
@export var wood = Global.wood
@export var speed := 1200

@export var home : House

@export var job = Job.LABORER
enum Job {
	NONE,
	LABORER,
	FARMER
}

@onready var tileMap : TileMapLayer = get_parent().get_parent().get_child(0)
@onready var treeTiles : TileMapLayer = tileMap.get_child(0)
@onready var grassTiles : TileMapLayer = tileMap.get_child(1)
@onready var holyTiles : TileMapLayer = tileMap.get_child(3)
@onready var farmTiles : TileMapLayer = tileMap.get_child(4)
@onready var anim: AnimationPlayer = %AnimationPlayer
@onready var nav: NavigationAgent2D = $NavigationAgent2D

signal day_passed
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

# Praying
var satisfaction : float = 50.0
var pray_is_on_cooldown : bool = false
var did_you_pray_today : bool = false

# Building
var build_queue : Array
var need_build : bool
var is_building : bool
var is_in_slot : bool
# Day / Night Cycle
var is_resting : bool = false
var is_sleeping : bool = false
var is_wander : bool = false

# Birth
@export var is_pregnant : bool
@export var is_child : bool
var birthday : int

func _ready() -> void:
	birthday = Global.day
	$EatTimer.wait_time = 20 # Global.total_day_time / 3
func _process(delta: float) -> void:
	# size - remove later
	scale = Vector2(0.75,0.75) if is_child else Vector2(1,1)
	
	# Trees
	treePosits = treeTiles.get_used_cells() if treeTiles != null else [Vector2.ZERO]
	for cellIndex in range(treePosits.size()):
		treePosits[cellIndex] = Vector2i(treeTiles.map_to_local(treePosits[cellIndex]).x,treeTiles.map_to_local(treePosits[cellIndex]).y)
	treesAround = treePosits.size()
	
	# plants
	plantHarvestTiles = unseedTiles.size() + grownTiles.size()
	%NeedPlantHarvest.max_value = farmTiles.get_used_cells().size()
	
	# building
	build_queue = grassTiles.get_used_cells_by_id(2,Vector2i(0,3),4)
	need_build = true if build_queue.size() > 0 else false
	
	# rest or sleep
	is_resting = true if Global.action_period == 1 else false
	is_sleeping = true if Global.action_period == 2 else false
	
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
	visible = true
	if _target == null:
		_target = null
		# if it's still looking for food, try to find a new target
		if looking_for_wood:
			find_wood()
		elif looking_for_farm:
			find_food()
			
		return
	nav.target_position = _target
	
	if looking_for_wood:
		if self.global_position.distance_to(_target) <= 20:
			chopping_tree()
			return
	
	if looking_for_farm:
		if self.global_position.distance_to(_target) <= 1:
			plant_seed()
			return
	if did_you_pray_today:
		if self.global_position.distance_to(_target) <= 15:
			go_pray()
			return
			
	if is_building:
		if self.global_position.distance_to(_target) <= 20:
			go_build()
			return
	if is_sleeping:
		if home == null:
			return
		find_bed()
		if self.global_position.distance_to(_target) <= 12:
			visible = false
			return
	if is_wander:
		if self.global_position.distance_to(_target) <= 12:
			if %WanderTimer.time_left <= 0:
				%WanderTimer.start()
			return
	#if self.global_position.distance_to(_target) <= 10:
		##$body.play("idle")
		#if looking_for_wood and treePosits.has(_target):
			#chopping_tree()
		#elif looking_for_farm :
			#plant_seed()
			#
			#
	
	move_to(self.global_position.direction_to(nav.get_next_path_position() ), delta)

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
	velocity = direction * speed * delta
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
	
	plant_or_harvest()
	
func plant_or_harvest():
	if Global.seeds > 0 and unseedTiles.size() > 0 and Global.food > 10:
		_get_closest_tile(unseedTiles)
		return
	if grownTiles.size() <= 0:
		_get_closest_tile(unseedTiles)
		return
	#otherwise
	_get_closest_tile(grownTiles)
	
func plant_seed():
	var mapTarget : Vector2i = farmTiles.local_to_map(_target)
	if farmTiles.get_cell_atlas_coords(mapTarget) == Vector2i(4,4):
		harvest(mapTarget)
		return
	if Global.seeds <= 0:
		find_food()
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

# Praying
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------------------

func find_shrine():
	var shrine_tile = holyTiles.get_used_cells_by_id(3,Vector2i(0,0))[0]
	_target = holyTiles.map_to_local(shrine_tile)

func go_pray():
	# play animation
	if is_child:
		Global.faith += 1
	if satisfaction > 85.0:
		Global.faith += 2
		return
	
	Global.faith += 1
	pray_is_on_cooldown = true
	%PrayCooldown.start()

# Building
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------------------

func find_building():
	for cellIndex in range(build_queue.size()):
		build_queue[cellIndex] = Vector2i(grassTiles.map_to_local(build_queue[cellIndex]).x,grassTiles.map_to_local(build_queue[cellIndex]).y)
	_get_closest_tile(build_queue)
	grassTiles.set_cell(_target,2,Vector2i(0,3),5)

func go_build():
	if need_build:
		var tile = grassTiles.local_to_map(_target)
		tileMap.place_house(tile)
		if build_queue.size() > 0:
			find_building()
			return
		is_in_slot = false
	else:
		return

# Sleep
# --------------------------------------------------------------------------------------------------------------------------------------------------------------

func find_bed():
	if home == null:
		_target = null
		return
	_target = home.bed.global_position
	
# Idle Wander
func wander():
	var WAN_DIS = 30
	var home_pos = global_position
	var des_pos = home_pos + Vector2(randf_range(-WAN_DIS,WAN_DIS),randf_range(-WAN_DIS,WAN_DIS))
	_target = des_pos

func _on_wander_timer_timeout() -> void:
	wander()

# Utility AI action change
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------------------

func _on_utility_ai_agent_top_score_action_changed(top_action_id: Variant) -> void:
	print("Action changed: %s" % top_action_id)
	match top_action_id:
		"go_pray":
			did_you_pray_today = clear_actions_and_set_current(true)
			find_shrine()
		"idle":
			is_wander = clear_actions_and_set_current(true)
			wander()
		"find_wood":
			looking_for_wood = clear_actions_and_set_current(true)
			find_wood()
		"farm_food":
			looking_for_farm = clear_actions_and_set_current(true)
			find_food()
		"go_build":
			is_building = clear_actions_and_set_current(true)
			find_building()
		"go_sleep":
			is_sleeping = clear_actions_and_set_current(true)
			find_bed()
		


func clear_actions_and_set_current(boolean : bool):
	looking_for_farm = false
	looking_for_wood = false
	did_you_pray_today = false
	is_building = false
	is_wander = false
	_target = null
	
	return boolean

# Needs (Hunger & Warmth) timers and resource use
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
func _on_eat_timer_timeout() -> void:
	if Global.food >= 1:
		satisfaction += 1.25
		Global.food -= 1
	else:
		satisfaction -= 1.25

func _on_pray_cooldown_timeout() -> void:
	pray_is_on_cooldown = false


func _on_day_passed() -> void:
	if Global.day - birthday == 2 and is_child:
		is_child = false
	if home == null:
		satisfaction -= 5.0
	if home != null:
		if Global.wood < 1:
			satisfaction -= 2.5
		else:
			Global.wood -= 1
			satisfaction += 1.5
