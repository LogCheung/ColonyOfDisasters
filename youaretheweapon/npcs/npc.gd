extends CharacterBody2D

const TOOL_DURABILITY : float = 20

var is_moving = false
var _target

var distance_from_target

@export var hunger = Global.food
@export var wood = Global.wood
@export var stone = Global.stone
@export var speed := 1200
@export var forge : Forge
@export var home : StaticBody2D
@export var has_tool : bool = true
@export var job = Job.LABORER
enum Job {
	NONE,
	LABORER,
	FARMER,
	BLACKSMITH,
	MINER
}
@onready var no_house: Sprite2D = $NoHouse
@onready var no_food: Sprite2D = $NoFood
@onready var no_fuel: Sprite2D = $NoFuel

@onready var tileMap : TileMapLayer = get_parent().get_parent().get_child(0)
@onready var treeTiles : TileMapLayer = tileMap.get_child(0)
@onready var grassTiles : TileMapLayer = tileMap.get_child(1)
@onready var holyTiles : TileMapLayer = tileMap.get_child(3)
@onready var farmTiles : TileMapLayer = tileMap.get_child(4)
@onready var stoneTiles : TileMapLayer = tileMap.get_child(6)
@onready var anim: AnimationPlayer = %AnimationPlayer
@onready var nav: NavigationAgent2D = $NavigationAgent2D

signal day_passed
# Occupation
var is_laborer : bool
var is_farmer : bool
var is_smith : bool
var is_miner : bool

# Trees and Wood and Stone
var looking_for_wood = false
var treePosits : Array

var looking_for_stone = false
var stonePosits : Array

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
@export var build_queue : Array
var need_build : bool
var is_building : bool
var is_in_slot : bool
var has_resources : bool
# Day / Night Cycle
var is_resting : bool = false
var is_sleeping : bool = false
var is_wander : bool = false

# Smithing / Forge
var has_ore : bool
var has_metal : bool
var tools : int = Global.tools
var is_smelting : bool = false
var is_forging : bool = false

var tool_uses_left : float

# Combat
var is_in_combat : bool
var marching : bool
var is_in_position : bool = false
@export var form_position : Marker2D

# Birth
@export var is_pregnant : bool
@export var is_child : bool
var birthday : int

# Needs
var ticks_without_food : int 
var days_without_warmth : int
var is_cold : bool

func _ready() -> void:
	birthday = Global.day
	tool_uses_left = TOOL_DURABILITY
	$EatTimer.wait_time = 40 # Global.total_day_time / 3
func _process(delta: float) -> void:
	if !is_in_combat:
		nav.avoidance_enabled = true
	
	# size - remove later
	scale = Vector2(0.75,0.75) if is_child else Vector2(1,1)
	
	#print(str(check) + " : " + str(_target))
	# Trees and stone
	treePosits = treeTiles.get_used_cells_by_id(1,Vector2i(0,0)) if treeTiles != null else [Vector2.ZERO]
	treePosits.append_array(treeTiles.get_used_cells_by_id(1,Vector2i(1,0)))
	for cellIndex in range(treePosits.size()):
		treePosits[cellIndex] = Vector2i(treeTiles.map_to_local(treePosits[cellIndex]).x,treeTiles.map_to_local(treePosits[cellIndex]).y)
	
	stonePosits = stoneTiles.get_used_cells()
	for cellIndex in range(stonePosits.size()):
		stonePosits[cellIndex] = Vector2i(stoneTiles.map_to_local(stonePosits[cellIndex]).x,stoneTiles.map_to_local(stonePosits[cellIndex]).y)
	
	# plants
	plantHarvestTiles = unseedTiles.size() + grownTiles.size()
	%NeedPlantHarvest.max_value = farmTiles.get_used_cells().size()
	
	# building
	build_queue = grassTiles.get_used_cells_by_id(2,Vector2i(0,3),4)
	build_queue.append_array(grassTiles.get_used_cells_by_id(2,Vector2i(0,3),6))
	need_build = true if build_queue.size() > 0 else false
	
	# Smithing
	has_metal = true if Global.metal >= 2 else false
	has_ore = true if Global.ore > 0 else false
	%hasTools.max_value = Global.adults * 1.5
	
	# rest or sleep
	is_resting = true if Global.action_period == 1 else false
	is_sleeping = true if Global.action_period == 2 else false
	
	#tools
	if tool_uses_left <= 0:
		if Global.tools >= 1:
			has_tool = true
			tool_uses_left = TOOL_DURABILITY
			Global.tools -= 1
		else:
			has_tool = false
	
	# handle
	
	_handle_target(delta)
	_handle_job()
	
	# Needs
	if home == null:
		no_house.visible = true
	else:
		no_house.visible = false
	if is_cold:
		no_fuel.visible = true
		if %ColdTimer.time_left <= 0:
			%ColdTimer.start()
		
	
	# distance
	distance_from_target = global_position.distance_to(_target) if _target else 1000000.0
	
	# global update
	has_seeds = true if Global.seeds > 0 else false
	wood = Global.wood
	stone = Global.stone

# Frame handling of target, occupation,
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------------------

func _handle_target(delta: float):
	visible = true
	#nav.avoidance_enabled = true
	
	if is_building:
		find_building()
	if _target == null:
		_target = null
		# if it's still looking for food, try to find a new target
		if looking_for_wood:
			find_wood()
		elif looking_for_farm:
			find_food()
		elif looking_for_stone:
			get_closest_tile(stonePosits)
		elif marching:
			go_to_formation()
		return
	nav.target_position = _target
	
	# Play animation before each action function (maybe remove action function)
	# make action function call in animation player once animation finished
	# for trees and stones, the animation will be long instead of repeated
	# add tool use after animation
	if looking_for_wood:
		if self.global_position.distance_to(_target) <= 20:
			anim.play("chop")
			return
	elif looking_for_stone:
		if self.global_position.distance_to(_target) <= 20:
			anim.play("mine")
			return
	elif looking_for_farm:
		if self.global_position.distance_to(_target) <= 4:
			if grownTiles.has(_target):
				anim.play("harvest")
			else:
				anim.play("plant")
			return
	elif did_you_pray_today:
		if self.global_position.distance_to(_target) <= 15:
			anim.play("pray")
			return
	elif is_building:
		if self.global_position.distance_to(_target) <= 20:
			anim.play("build")
			return
	elif is_sleeping:
		nav.avoidance_enabled = false
		if home == null:
			return
		find_bed()
		if self.global_position.distance_to(_target) <= 12:
			visible = false
			return
	elif is_wander:
		if self.global_position.distance_to(_target) <= 12:
			if %WanderTimer.time_left <= 0:
				%WanderTimer.start()
			return
	elif is_smelting:
		if self.global_position.distance_to(_target) <= 5:
			anim.play("smelt")
			return
	elif is_forging:
		if self.global_position.distance_to(_target) <= 5:
			anim.play("forge")
			return
	elif marching:
		if self.global_position.distance_to(_target) <= 6:
			go_to_formation()
			is_in_position = true
			_target = null
			return
		else:
			is_in_position = false
			go_to_formation()
			
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
		Job.NONE:
			is_farmer = false
			is_laborer = false
			is_smith = false
			is_miner = false
		Job.LABORER:
			is_farmer = false
			is_laborer = true # current job
			is_smith = false
			is_miner = false
		Job.FARMER:
			is_farmer = true # current job
			is_laborer = false
			is_smith = false
			is_miner = false
		Job.BLACKSMITH:
			is_farmer = false
			is_laborer = false
			is_smith = true
			is_miner = false
		Job.MINER:
			is_farmer = false
			is_laborer = false
			is_smith = false
			is_miner = true

func move_to(direction, delta):
	is_moving = true
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
	move_and_slide()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

# Woodcutting and Stone
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
func adjust_tree_nav():
	var grass_used = grassTiles.get_used_cells()
	var cells_under_tree : Array
	for cell in grass_used:
		var grassToTree = treeTiles.local_to_map(grassTiles.map_to_local(cell))
		var grassToStone = stoneTiles.local_to_map(grassTiles.map_to_local(cell))
		if treeTiles.get_used_cells().has(grassToTree) or stoneTiles.get_used_cells().has(grassToStone):
			grassTiles.set_cell(cell,2,Vector2i(0,3),7)
		#if stoneTiles.get_used_cells().has(grassToStone):
			#grassTiles.set_cell(cell,2,Vector2i(0,3),7)
	var non_nav_used = grassTiles.get_used_cells_by_id(2,Vector2i(0,3),7)
	for cell in non_nav_used:
		var grassToTree = treeTiles.local_to_map(grassTiles.map_to_local(cell))
		var grassToStone = stoneTiles.local_to_map(grassTiles.map_to_local(cell))
		if !treeTiles.get_used_cells().has(grassToTree) and !stoneTiles.get_used_cells().has(grassToStone):
			grassTiles.set_cell(cell,2,Vector2i(0,3))
		#if !stoneTiles.get_used_cells().has(grassToStone):
			#grassTiles.set_cell(cell,2,Vector2i(0,3))
			
			
func chopping_tree():
	var target_tile : TileData = treeTiles.get_cell_tile_data(treeTiles.local_to_map(_target))
	if not target_tile:
		find_wood()
		return
	
	var target_reward = target_tile.get_custom_data("Wood")
	var target_health = target_tile.get_custom_data("Health")
	
	tool_uses_left -= 2
	Global.wood = Global.wood + target_reward
	treeTiles.set_cell(treeTiles.local_to_map(_target),-1)
	if treePosits.has(Vector2i(_target.x,_target.y)):
		treePosits.remove_at(treePosits.find(Vector2i(_target.x,_target.y)))
	adjust_tree_nav()
	_target = null

func cutting_stone():
	if _target == null:
		get_closest_tile(stonePosits)
		return
	var target_tile = stoneTiles.get_cell_tile_data(stoneTiles.local_to_map(_target))
	if not target_tile:
		return
	
	var target_reward = target_tile.get_custom_data("Stone")
	var target_health = target_tile.get_custom_data("Health")
	
	tool_uses_left -= 2
	Global.stone = Global.stone + target_reward
	stoneTiles.set_cell(stoneTiles.local_to_map(_target),-1)
	if stonePosits.has(_target):
		stonePosits.remove_at(stonePosits.find(_target))
	adjust_tree_nav()
	_target = null
func find_wood():
	var closest = _get_closest_wood()
	if closest != null:
		_target = closest

func _get_closest_wood():
	var posits : Array = treePosits
	
	for unit in get_tree().get_nodes_in_group("ADULT"):
		if unit._target == null:
			continue
		if unit == self:
			continue
		if posits.has(Vector2i(unit._target.x,unit._target.y)):
			posits.remove_at(posits.find(Vector2i(unit._target.x,unit._target.y)))
	
	var closest = null
	var closest_distance = null
	for pos in posits:
		var dist = self.global_position.distance_to(pos)
		if closest_distance == null or closest_distance > dist:
			closest_distance = dist
			closest = pos
	return closest

# Farming
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------------------

func get_closest_tile(posits : Array):
	for unit in get_tree().get_nodes_in_group("ADULT"):
		if unit._target == null:
			continue
		if unit == self:
			continue
		if posits.has(Vector2i(unit._target.x,unit._target.y)):
			posits.remove_at(posits.find(Vector2i(unit._target.x,unit._target.y)))
	
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
		get_closest_tile(unseedTiles)
		return
	if grownTiles.size() <= 0:
		get_closest_tile(unseedTiles)
		return
	#otherwise
	get_closest_tile(grownTiles)
	
func plant_seed():
	var mapTarget : Vector2i = farmTiles.local_to_map(_target)
	if farmTiles.get_cell_atlas_coords(mapTarget) == Vector2i(4,4):
		harvest()
		return
	if Global.seeds <= 0:
		find_food()
		return
	
	var target_tile : TileData = farmTiles.get_cell_tile_data(farmTiles.local_to_map(_target))
	if not target_tile:
		return
	var curWet = target_tile.get_custom_data("wet")
	farmTiles.set_cell(mapTarget, 1,  Vector2i(farmTiles.get_cell_atlas_coords(mapTarget).x + 1,farmTiles.get_cell_atlas_coords(mapTarget).y ),curWet)
	unseedTiles = farmTiles.get_used_cells_by_id(1,Vector2(0,4))
	tileMap.seed_planted.emit(mapTarget)
	Global.seeds -= 1
	tool_uses_left -= 1
	_target = null


func harvest():
	var mapTarget : Vector2i = farmTiles.local_to_map(_target)
	var target_tile : TileData = farmTiles.get_cell_tile_data(mapTarget)
	if not target_tile:
		return
	var curWet = target_tile.get_custom_data("wet")
	farmTiles.set_cell(mapTarget, 1,  Vector2i(0,4),curWet)
	grownTiles = farmTiles.get_used_cells_by_id(1,Vector2(4,4))
	Global.food += 2
	tool_uses_left -= 1
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
	get_closest_tile(build_queue)

func go_build():
	var build_land = grassTiles.get_used_cells_by_id(2,Vector2i(0,3),4)
	build_land.append_array(grassTiles.get_used_cells_by_id(2,Vector2i(0,3),6))
	if need_build:
		var tile = grassTiles.local_to_map(_target)
		if !build_land.has(tile):
			return
			
		if grassTiles.get_cell_tile_data(tile).get_custom_data("forge"):
			if Global.wood >= 8 and Global.stone >= 12:
				tileMap.place_forge(tile)
		else:
			if Global.wood >= 10 and Global.stone >= 2:
				tileMap.place_house(tile)
		tool_uses_left -= 4
		if build_queue.size() > 0:
			_target = null
			find_building()
			return
		is_in_slot = false
		need_build = false
	else:
		_target = null
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
	if is_in_combat:
		return
	wander()

# Smith
# --------------------------------------------------------------------------------------------------
func find_furnace():
	if forge == null:
		_target = null
		return
	_target = forge.furnace.global_position
func make_metal():
	if !Global.ore >= 1:
		has_ore = false
		return
	tool_uses_left -= 1
	Global.ore -= 1
	Global.metal += 1

func find_smithy():
	if forge == null:
		_target = null
		return
	_target = forge.smithy.global_position

func make_tool():
	if !Global.metal >= 2:
		has_metal = false
		return 
	tool_uses_left -= 1
	Global.metal -= 2
	Global.tools += 1

# Combat
func go_to_formation():
	if form_position == null:
		return
	#print(form_position.global_position)
	_target = form_position.global_position

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
		"find_stone":
			looking_for_stone = clear_actions_and_set_current(true)
			get_closest_tile(stonePosits)
		"farm_food":
			looking_for_farm = clear_actions_and_set_current(true)
			find_food()
		"go_build":
			is_building = clear_actions_and_set_current(true)
			find_building()
		"go_sleep":
			is_sleeping = clear_actions_and_set_current(true)
			find_bed()
		"go_smelt":
			is_smelting = clear_actions_and_set_current(true)
			find_furnace()
		"go_forge":
			is_forging = clear_actions_and_set_current(true)
			find_smithy()
		"go_fight":
			marching = clear_actions_and_set_current(true)
			go_to_formation()
		
func clear_actions_and_set_current(boolean : bool):
	marching = false
	is_forging = false
	is_smelting = false
	looking_for_stone = false
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
	if is_in_combat:
		return
	if Global.food >= 1:
		no_food.visible = false
		satisfaction += 1.25
		Global.food -= 1
		ticks_without_food = 0
	else:
		ticks_without_food += 1
		no_food.visible = true
		satisfaction -= 1.25
	
	if ticks_without_food >= 6:
		# play death animation
		clear_roles()
		queue_free()

func _on_pray_cooldown_timeout() -> void:
	pray_is_on_cooldown = false


func _on_day_passed() -> void:
	if Global.day - birthday == 2 and is_child:
		is_child = false
	if home == null:
		no_house.visible = true
		if Global.winter:
			satisfaction -= 2.5
		satisfaction -= 5.0
	if home != null:
		if Global.wood < 1:
			days_without_warmth += 1
			if Global.winter:
				satisfaction -= 1.5
			satisfaction -= 2.5
		else:
			if %ColdTimer.time_left > 0:
				%ColdTimer.stop()
				Global.wood -= 1
			no_fuel.visible = true
			if Global.winter:
				Global.wood -= 1
			Global.wood -= 1
			days_without_warmth = 0
			satisfaction += 1.5
	if days_without_warmth >= 2:
		# play death animation
		clear_roles()
		queue_free()

func clear_roles():
	if forge:
		forge.worker = null
		forge = null
	if home:
		if home.slot1 == self:
			home.slot1 = null
		else:
			home.slot2 = null
	if Global.builder_slots.has(self):
		Global.builder_slots.remove_at(Global.builder_slots.find(self))
	job = 0
	clear_actions_and_set_current(false)


func _on_cold_timer_timeout() -> void:
	satisfaction -= 2
	is_cold = false
	no_fuel.visible = false
	Global.wood -= 1
