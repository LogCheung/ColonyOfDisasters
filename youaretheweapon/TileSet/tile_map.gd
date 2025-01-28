extends TileMapLayer

var HOUSE = preload("res://TileSet/House/house.tscn")
var FORGE = preload("res://TileSet/Forge/forge.tscn")
var NPC  = preload("res://npcs/npc.tscn")
var BANNER = preload("res://Banner/banner.tscn")

@export var total_grow_time : float = 15.0


@onready var world : Node2D = get_parent()
@onready var grass: TileMapLayer = %Grass
@onready var hover: TileMapLayer = %Hover
@onready var holy: TileMapLayer = %Holy
@onready var farm: TileMapLayer = %Farm
@onready var house: TileMapLayer = %House
@onready var tree: TileMapLayer = %TreeTiles
@onready var stone: TileMapLayer = %Stone
@onready var road: TileMapLayer = %Road

signal seed_planted(cell: Vector2i)
signal day_is_passed()

var farm_tiles : int

var grid_size = 320
var dic = {}
var holy_land
var tree_gridx = 36
var tree_gridy = 24

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in grid_size:
		for y in grid_size:
			dic[str(Vector2(x,y))] = {
				"Type" : "hover"
			}
			#set_cell(0,Vector2(x,y),2,Vector2(0,0))
	spawn_resources()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
	
	holy_land = grass.get_used_cells_by_id(2,Vector2(0,3),1)
	farm_tiles = farm.get_used_cells().size()
	var tile = local_to_map(get_global_mouse_position())
	for x in grid_size:
		for y in grid_size:
			hover.erase_cell(Vector2(x,y))
			pass
	if dic.has(str(tile)):
		apply_hover_effect(tile)
		pass
		
# Initial Resource Generation
# ------------------------------------------------
func spawn_resources():
	var grass_used = grass.get_used_cells()
	tree.clear()
	stone.clear()
	var positionsTree : Array
	var positionsStone : Array
	for i in range(150):
		var xcoor = (randi() % int(tree_gridx - 3) + 3)
		var ycoor = (randi() % int(tree_gridy - 3))
		var grid_pos = Vector2i(xcoor,ycoor)
		if positionsTree.has(grid_pos):
			continue
		positionsTree.append(grid_pos)
	for i in range(65):
		var xcoor = (randi() % int(74 - 3) + 3)
		var ycoor = (randi() % int(35 - 3))
		var grid_pos = Vector2i(xcoor,ycoor)
		var grid_pos_check = stone.map_to_local(grid_pos)
		grid_pos_check = tree.local_to_map(grid_pos_check)
		if positionsTree.has(grid_pos_check) or positionsStone.has(grid_pos):
			continue
		positionsStone.append(grid_pos)
	
	for cell in positionsTree:
		if randi() % 2 == 1:
			tree.set_cell(cell,1,Vector2i(1,0))
		else:
			tree.set_cell(cell,1,Vector2i(0,0))
	for cell in positionsStone:
		if randi() % 2 == 1:
			stone.set_cell(cell,0,Vector2i(0,1))
		else:
			stone.set_cell(cell,0,Vector2i(0,0))
		
	for cell in grass_used:
		var grassToTree = tree.local_to_map(grass.map_to_local(cell))
		if positionsTree.has(grassToTree):
			grass.set_cell(cell,2,Vector2i(0,3),7)
			
	for cell in grass_used:
		var grassToStone = stone.local_to_map(grass.map_to_local(cell))
		if positionsStone.has(grassToStone):
			grass.set_cell(cell,2,Vector2i(0,3),7)
	
	pass


# ---------------------------------
func apply_hover_effect(tile):
	match world.power:
		0:
			hover.set_cell(tile,0,Vector2(0,0))
		1:
			hover.set_cell(Vector2(tile.x - 1,tile.y + 1),0,Vector2(1,1)) # bot left - +
			hover.set_cell(Vector2(tile.x + 1,tile.y + 1),0,Vector2(2,1)) # bot right + + 
			hover.set_cell(Vector2(tile.x + 1,tile.y - 1),0,Vector2(2,0)) # top left + -
			hover.set_cell(Vector2(tile.x - 1,tile.y - 1),0,Vector2(1,0)) # right - -
		2:
			hover.set_cell(Vector2(tile.x,tile.y),0,Vector2(1,1)) # bot left = =
			hover.set_cell(Vector2(tile.x + 1,tile.y),0,Vector2(2,1)) # bot right + =
			hover.set_cell(Vector2(tile.x,tile.y - 1),0,Vector2(1,0)) # top left = -
			hover.set_cell(Vector2(tile.x + 1,tile.y - 1),0,Vector2(2,0)) # top right + -
		3:
			hover.set_cell(Vector2(tile.x-1,tile.y-1),0,Vector2(1,0))
			hover.set_cell(Vector2(tile.x-1,tile.y),0,Vector2(1,1))
			hover.set_cell(Vector2(tile.x+1,tile.y-1),0,Vector2(2,0))
			hover.set_cell(Vector2(tile.x+1,tile.y),0,Vector2(2,1))
				
			#hover.set_cell(Vector2(tile.x,tile.y+1),0,Vector2(1,1))
			#hover.set_cell(Vector2(tile.x,tile.y-1),0,Vector2(1,0))
			#hover.set_cell(Vector2(tile.x+1,tile.y-1),0,Vector2(2,0))
			#hover.set_cell(Vector2(tile.x+1,tile.y+1),0,Vector2(2,1))
		4:
			hover.set_cell(Vector2(tile.x - 2,tile.y + 2),0,Vector2(1,1))
			hover.set_cell(Vector2(tile.x + 2,tile.y + 2),0,Vector2(2,1))
			hover.set_cell(Vector2(tile.x + 2,tile.y - 2),0,Vector2(2,0))
			hover.set_cell(Vector2(tile.x - 2,tile.y - 2),0,Vector2(1,0))
		5:
			hover.set_cell(tile,1,Vector2i(0,0),1)
			hover.set_cell(Vector2(tile.x - 2,tile.y + 2),0,Vector2(1,1))
			hover.set_cell(Vector2(tile.x + 2,tile.y + 2),0,Vector2(2,1))
			hover.set_cell(Vector2(tile.x + 2,tile.y - 2),0,Vector2(2,0))
			hover.set_cell(Vector2(tile.x - 2,tile.y - 2),0,Vector2(1,0))
	if Input.is_action_just_pressed("SummonWeather"):
		if Global.winter:
			apply_to_raiders(tile)
			encourage_building(tile)
			affect_resources(tile)
		else:
			apply_to_raiders(tile)
			affect_resources(tile)
			encourage_building(tile)
	pass
	
	
func encourage_building(tile : Vector2i):
	var used_tiles = get_used_tiles()
	var power = world.power
	world.power = 0
	print(power)
	if !holy_land.has(tile) and power != 4 and power != 5:
		return
	if too_close_to_shrine():
		print("wow")
		return
	match power:
		0:
			pass
		1:
			var build_used = grass.get_used_cells_by_id(2,Vector2i(0,3),4)
			build_used.append_array(grass.get_used_cells_by_id(2,Vector2i(0,3),5))
			for x in range(tile.x -1,tile.x+2):
				for y in range(tile.y-1,tile.y+2):
					if farm.get_used_cells().has(Vector2i(x,y)):
						continue
					if holy_land.has(Vector2i(x,y)) and !build_used.has(Vector2i(x,y)):
						farm.set_cell(Vector2(x,y),1,Vector2(0,4))
			if Global.winter:
				affect_resources_winter(tile,power)
		2:
			var build_used = grass.get_used_cells_by_id(2,Vector2i(0,3),4)
			build_used.append_array(grass.get_used_cells_by_id(2,Vector2i(0,3),6))
			if house_too_close() or forge_too_close():
				return
			for cell in build_used:
				if tile.distance_to(cell) < 3:
					return
			for x in range(tile.x,tile.x+2):
				for y in range(tile.y-1,tile.y + 1):
					if !holy_land.has(Vector2i(x,y)) or used_tiles.has(Vector2i(x,y)):
						return
			grass.set_cell(tile,2,Vector2i(0,3),4)
			if Global.winter:
				affect_resources_winter(tile,power)
		3:
			var build_used = grass.get_used_cells_by_id(2,Vector2i(0,3),4)
			build_used.append_array(grass.get_used_cells_by_id(2,Vector2i(0,3),6))
			if house_too_close() or forge_too_close():
				return
			for cell in build_used:
				if tile.distance_to(cell) < 3:
					return
			for x in range(tile.x -1,tile.x+2):
				for y in range(tile.y-1,tile.y + 1):
					if !holy_land.has(Vector2i(x,y)) or used_tiles.has(Vector2i(x,y)):
						return
			grass.set_cell(tile,2,Vector2i(0,3),6)
		4:
			var shrine_tile = holy.get_used_cells_by_id(3,Vector2i(0,0))[0]
			for x in range(tile.x -2,tile.x+3):
				for y in range(tile.y-2,tile.y+3):
					if holy.map_to_local(Vector2i(x,y)).distance_to(holy.map_to_local(shrine_tile)) < 48:
						continue
					grass.set_cell(Vector2i(x,y),2,Vector2i(0,3),1)
					holy.set_cell(Vector2i(x,y),2,Vector2i(0,0,))
		5:
			var road_tiles : Array
			var spawned : int
			for x in range(tile.x -2,tile.x+3):
				for y in range(tile.y-2,tile.y+3):
					road_tiles.append(Vector2i(x,y))
					if spawned < 6:
						var npc = NPC.instantiate()
						npc.global_position = grass.map_to_local(tile)
						world.get_child(3).add_child(npc)
						spawned += 1
			road.set_cells_terrain_connect(road_tiles,0,1)
			holy.set_cell(tile,3,Vector2i(0,0))
			grass.set_cell(tile,2,Vector2i(0,3),5)
			
	
func affect_resources(tile) -> void:
	var farm_used = farm.get_used_cells()
	var build_used = grass.get_used_cells_by_id(2,Vector2i(0,3),4)
	var tree_used = tree.get_used_cells_by_id(1,Vector2i(0,0))
	tree_used.append_array(tree.get_used_cells_by_id(1,Vector2i(1,0)))
	build_used.append_array(grass.get_used_cells_by_id(2,Vector2i(0,3),5))
	match world.power:
		1:
			if Global.winter:
				return
			for x in range(tile.x -1,tile.x+2):
				for y in range(tile.y-1,tile.y+2):
					if farm_used.has(Vector2i(x,y)):
						var tile_data : TileData = farm.get_cell_tile_data(Vector2i(x,y))
						var tile_atlas : Vector2i = farm.get_cell_atlas_coords(Vector2i(x,y))
						var curWet : int = tile_data.get_custom_data("wet")
						if curWet == 2:
							initiate_flood(Vector2i(tile))
							return
						farm.set_cell(Vector2i(x,y),1,tile_atlas,curWet + 1)
		2:
			if Global.winter:
				return
			var farm_in_range : int = 0
			var non_farm : int
			var tree_in_range : bool
			for x in range(tile.x,tile.x+2):
				for y in range(tile.y-1,tile.y + 1):
					if build_used.has(Vector2i(x,y)):
						continue
					if farm_used.has(Vector2i(x,y)):
						farm_in_range += 1
						
					var tile_world = hover.map_to_local(Vector2i(x,y))
					tile_world = tree.local_to_map(tile_world)
					if tree_used.has(tile_world):
						tree_in_range = true
			if tree_in_range:
				plant_trees(tile)
			for i in range(farm_in_range):
				Global.seeds += 3
		3:
			var stone_world = stone.get_used_cells()
			var ore_spots : Array
			for x in range(tile.x -1,tile.x+2):
				for y in range(tile.y-1,tile.y + 1):
					if holy_land.has(Vector2i(x,y)):
						continue
					if build_used.has(Vector2i(x,y)):
						continue
					if farm_used.has(Vector2i(x,y)):
						farm.set_cell(Vector2i(x,y),-1)
					var tile_world = hover.map_to_local(Vector2i(x,y))
					tile_world = tree.local_to_map(tile_world)
					if tree_used.has(tile_world):
						tree.set_cell(tile_world,-1)
						tree_used = tree.get_used_cells_by_id(1,Vector2i(0,0))
						tree_used.append_array(tree.get_used_cells_by_id(1,Vector2i(1,0)))
						Global.wood += 6
						continue
					var tile_stone = stone.local_to_map(hover.map_to_local(Vector2i(x,y)))
					if !stone_world.has(tile_stone):
						ore_spots.append(tile_stone)
			for cell in ore_spots:
				# make random chance to not spawn some
				var rand2 : int = randi() % 2
				if rand2 == 0:
					stone.set_cell(cell,0,Vector2i(1,0))
				else:
					stone.set_cell(cell,0,Vector2i(1,1))

func apply_to_raiders(tile):
	var enemies_check = get_tree().get_first_node_in_group("ENEMY")
	if !is_instance_valid(enemies_check):
		return
	var enemies = get_tree().get_nodes_in_group("ENEMY")
	var banner = get_tree().get_first_node_in_group("ALLYBANNER")
	match world.power:
		1:
			for unit in enemies:
				if unit.global_position.distance_to(map_to_local(tile)) < 32:
					banner.player_bias += 2 if Global.winter else 1
					return
		2:
			for unit in enemies:
				if unit.global_position.distance_to(map_to_local(tile)) < 32:
					banner.player_bias += 1
					return
		3: 
			var killed = 0
			for unit in enemies:
				print("ok")
				if killed >= 3:
					return
				if unit.global_position.distance_to(map_to_local(tile)) < 32:
					var rand = randi() % 10
					if rand < 3:
						unit.queue_free()
						killed += 1
	pass

func get_used_tiles() -> Array:
	var farm_used = farm.get_used_cells()
	var soon_build_used = grass.get_used_cells_by_id(2,Vector2i(0,3),4)
	var tiles_with_building = grass.get_used_cells_by_id(2,Vector2i(0,3),5)
	
	var used_tiles : Array
	used_tiles.append_array(farm_used)
	used_tiles.append_array(soon_build_used)
	used_tiles.append_array(tiles_with_building)
	return used_tiles

func too_close_to_shrine() -> bool:
	var shrine_tile = holy.get_used_cells_by_id(3,Vector2i(0,0))
	if shrine_tile.is_empty():
		return false
	else:
		shrine_tile = shrine_tile[0]
	if get_global_mouse_position().distance_to(holy.map_to_local(shrine_tile)) < 48:
		return true
	return false

# Rain and plants
# -------------------------------------------------------------
func _on_seed_planted(cell) -> void:
	var tile_data : TileData = farm.get_cell_tile_data(cell)
	if tile_data == null:
		return
	var curWet : int = get_water_of_cell(cell)
	var phase_time : float = get_grow_time(cell)
	print(phase_time)
	# grow
	#var growingTile = farm.get_cell_tile_data(tileCoords)
	await get_tree().create_timer(phase_time).timeout
	tile_data = farm.get_cell_tile_data(cell)
	if tile_data == null:
		return
	phase_time = get_grow_time(cell)
	curWet = get_water_of_cell(cell)
	farm.set_cell(cell,1,Vector2i(2,4),curWet)
	print(phase_time)
	
	await get_tree().create_timer(phase_time).timeout
	tile_data = farm.get_cell_tile_data(cell)
	if tile_data == null:
		return
	phase_time = get_grow_time(cell)
	curWet = get_water_of_cell(cell)
	farm.set_cell(cell,1,Vector2i(3,4),curWet)
	print(phase_time)
	
	await get_tree().create_timer(phase_time).timeout
	farm.set_cell(cell,1,Vector2i(4,4),curWet)
	
func get_grow_time(cell : Vector2i) -> float:
	var tile_data : TileData = farm.get_cell_tile_data(cell)
	var curWet : int = tile_data.get_custom_data("wet")
	var phase_time : float
	if curWet > 0:
		phase_time = total_grow_time / (1.0 * 3) - (1 * curWet)
		#phase_time = (total_grow_time * (.85 - (.05 * (grass.get_cell_tile_data(cell).get_custom_data("wet") - 1) ) ) )
	else:
		phase_time = total_grow_time / (1.0 * 3)
	
	if Global.winter:
		phase_time *= 1.25
	return phase_time

func get_water_of_cell(cell) -> int:
	var tile_data : TileData = farm.get_cell_tile_data(cell)
	var curWet : int = tile_data.get_custom_data("wet")
	return curWet

func _on_day_is_passed() -> void:
	for cell in farm.get_used_cells():
		var data = farm.get_cell_tile_data(cell)
		var atlas = farm.get_cell_atlas_coords(cell)
		var water = data.get_custom_data("wet")
		if water > 0:
			farm.set_cell(cell,1,atlas,water - 1)
	for cell in tree.get_used_cells_by_id(1,Vector2i(3,0)):
		if randi() % 2 == 1:
			tree.set_cell(cell,1,Vector2i(1,0))
		else:
			tree.set_cell(cell,1,Vector2i(0,0))

func initiate_flood(tile):
	await get_tree().create_timer(.2).timeout
	for x in range(tile.x -2,tile.x+3):
		for y in range(tile.y-2,tile.y+3):
			if farm.get_used_cells().has(Vector2i(x,y)):
				farm.set_cell(Vector2i(x,y),-1)
			if grass.get_used_cells_by_id(2,Vector2i(0,3),5).has(Vector2i(x,y)):
				grass.set_cell(Vector2i(x,y),2,Vector2i(0,3),1)
				
	pass
# Wind
# -------------------------------------
func house_too_close() -> bool:
	var placedHomes = get_tree().get_nodes_in_group("HOUSE")
	for home in placedHomes:
		if abs(get_global_mouse_position().y - home.global_position.y) < 16 :
			if get_global_mouse_position().distance_to(home.global_position) > 40:
				return false
			else:
				return true
		if abs(get_global_mouse_position().x - home.global_position.x) < 16 :
			if get_global_mouse_position().distance_to(home.global_position) > 40:
				return false
			else: 
				return true
		if get_global_mouse_position().distance_to(home.global_position) < 48:
			return true
	return false
	
func forge_too_close() -> bool:
	var placedForge = get_tree().get_nodes_in_group("FORGE")
	for home in placedForge:
		if abs(get_global_mouse_position().y - home.global_position.y) < 10 :
			if get_global_mouse_position().distance_to(home.global_position) > 40:
				return false
			else:
				return true
		if abs(get_global_mouse_position().x - home.global_position.x) < 16 :
			if get_global_mouse_position().distance_to(home.global_position) > 40:
				return false
			else: 
				return true
		if get_global_mouse_position().distance_to(home.global_position) < 48:
			return true
	return false

func place_house(tile : Vector2i):
	var house = HOUSE.instantiate()
	house.global_position = tile
	get_parent().add_child(house)
	Global.wood -= 10
	Global.stone -= 2
	#house.global_position = local_to_map(house.global_position)
	house.global_position = map_to_local(house.global_position)
	for x in range(tile.x,tile.x+2):
		for y in range(tile.y-1,tile.y+1):
			grass.set_cell(Vector2i(x,y),2,Vector2i(0,3),5)

func plant_trees(tile : Vector2i):
	var planted : int = 0
	var tree_used = tree.get_used_cells()
	var tile_world = grass.map_to_local(tile)
	var stone_world = stone.get_used_cells().map(stone.map_to_local).map(tree.local_to_map)
	tile = tree.local_to_map(tile_world)
	for x in range(tile.x - 1,tile.x+2):
		for y in range(tile.y-1,tile.y + 2):
			if Global.winter:
				if planted >= 2:
					break
			else:
				if planted >= 3:
					break
			if !tree_used.has(Vector2i(x,y)) and randi() % 6 <= 2 and !stone_world.has(Vector2i(x,y)):
				tree.set_cell(Vector2i(x,y),1,Vector2i(3,0))
				planted += 1
					
	
# Quake
# --------------------------------------------------------------------------------------------------
func place_forge(tile : Vector2i):
	var forge = FORGE.instantiate()
	forge.global_position = tile
	get_parent().add_child(forge)
	Global.wood -= 8
	Global.stone -= 12
	#house.global_position = local_to_map(house.global_position)
	forge.global_position = map_to_local(forge.global_position)
	for x in range(tile.x-1,tile.x+2):
		for y in range(tile.y-1,tile.y+1):
			grass.set_cell(Vector2i(x,y),2,Vector2i(0,3),5)

# Affect continued
func affect_resources_winter(tile, power : int):
	await get_tree().create_timer(.4).timeout
	
	var farm_used = farm.get_used_cells()
	var build_used = grass.get_used_cells_by_id(2,Vector2i(0,3),4)
	var tree_used = tree.get_used_cells_by_id(1,Vector2i(0,0))
	tree_used.append_array(tree.get_used_cells_by_id(1,Vector2i(1,0)))
	build_used.append_array(grass.get_used_cells_by_id(2,Vector2i(0,3),5))
	match power:
		1:
			apply_cold(tile)
			for x in range(tile.x -1,tile.x+2):
				for y in range(tile.y-1,tile.y+2):
					if farm_used.has(Vector2i(x,y)):
						var tile_data : TileData = farm.get_cell_tile_data(Vector2i(x,y))
						var tile_atlas : Vector2i = farm.get_cell_atlas_coords(Vector2i(x,y))
						var curWet : int = tile_data.get_custom_data("wet")
						var rand : int = randi() % 10
						if rand >= 2:
							farm.set_cell(Vector2i(x,y),-1)
						else:
							if curWet + 1 > 2:
								farm.set_cell(Vector2i(x,y),1,tile_atlas,curWet)
							else:
								farm.set_cell(Vector2i(x,y),1,tile_atlas,curWet + 1)
		2:
			apply_cold(tile)
			var farm_in_range : int = 0
			var non_farm : int
			var tree_in_range : bool
			for x in range(tile.x,tile.x+2):
				for y in range(tile.y-1,tile.y + 1):
					if build_used.has(Vector2i(x,y)):
						continue
					if farm_used.has(Vector2i(x,y)):
						farm_in_range += 1
						
					var tile_world = hover.map_to_local(Vector2i(x,y))
					tile_world = tree.local_to_map(tile_world)
					if tree_used.has(tile_world):
						tree_in_range = true
			if tree_in_range:
				plant_trees(tile)
			for i in range(farm_in_range):
				Global.seeds += 1

func apply_cold(tile):
	var nearby_adults = get_tree().get_nodes_in_group("ADULT")
	for unit in nearby_adults:
		if unit.global_position.distance_to(grass.map_to_local(tile)) < 50:
			unit.is_cold = true


func initiate_raid():
	var shrine_tile = holy.get_used_cells_by_id(3,Vector2i(0,0))
	var banner_tile = shrine_tile[0] + Vector2i(0,2)
	
	var banner = BANNER.instantiate()
	banner.global_position = holy.map_to_local(banner_tile)
	get_parent().add_child(banner)
	pass
