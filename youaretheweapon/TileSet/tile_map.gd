extends TileMapLayer

var HOUSE = preload("res://TileSet/House/house.tscn")

@export var total_grow_time : float = 6.0


@onready var world : Node2D = get_parent()
@onready var grass: TileMapLayer = %Grass
@onready var hover: TileMapLayer = %Hover
@onready var holy: TileMapLayer = %Holy
@onready var farm: TileMapLayer = %Farm
@onready var house: TileMapLayer = %House
@onready var tree: TileMapLayer = %TreeTiles

signal seed_planted(cell: Vector2i)

var farm_tiles : int

var grid_size = 160
var dic = {}
var holy_land

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in grid_size:
		for y in grid_size:
			dic[str(Vector2(x,y))] = {
				"Type" : "hover"
			}
			#set_cell(0,Vector2(x,y),2,Vector2(0,0))
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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

func apply_hover_effect(tile):
	if world.power == 5:
		hover.set_cell(Vector2(tile.x - 2,tile.y + 2),0,Vector2(1,1))
		hover.set_cell(Vector2(tile.x + 2,tile.y + 2),0,Vector2(2,1))
		hover.set_cell(Vector2(tile.x + 2,tile.y - 2),0,Vector2(2,0))
		hover.set_cell(Vector2(tile.x - 2,tile.y - 2),0,Vector2(1,0))
	elif world.power == 1:
		hover.set_cell(Vector2(tile.x - 1,tile.y + 1),0,Vector2(1,1)) # bot left - +
		hover.set_cell(Vector2(tile.x + 1,tile.y + 1),0,Vector2(2,1)) # bot right + + 
		hover.set_cell(Vector2(tile.x + 1,tile.y - 1),0,Vector2(2,0)) # top left + -
		hover.set_cell(Vector2(tile.x - 1,tile.y - 1),0,Vector2(1,0)) # right - -
	elif world.power == 2:
		hover.set_cell(Vector2(tile.x,tile.y),0,Vector2(1,1)) # bot left = =
		hover.set_cell(Vector2(tile.x + 1,tile.y),0,Vector2(2,1)) # bot right + =
		hover.set_cell(Vector2(tile.x,tile.y - 1),0,Vector2(1,0)) # top left = -
		hover.set_cell(Vector2(tile.x + 1,tile.y - 1),0,Vector2(2,0)) # top right + -
	else:
		hover.set_cell(tile,0,Vector2(0,0))
	
	if Input.is_action_just_pressed("SummonWeather"):
		encourage_building(tile)
		gain_resources(tile)
	pass
	
	
func encourage_building(tile):
	var used_tiles = get_used_tiles()
	
	if !holy_land.has(tile) and world.power != 5:
		return
	if too_close_to_shrine():
		return
	match world.power:
		0:
			pass
		1:
			for x in range(tile.x -1,tile.x+2):
				for y in range(tile.y-1,tile.y+2):
					if holy_land.has(Vector2i(x,y)) and used_tiles.has(Vector2i(x,y)):
						farm.set_cell(Vector2(x,y),1,Vector2(0,4))
					#else:
						#grass.set_cell(Vector2(x,y),2,Vector2(0,3))
		2:
			var placedHomes = get_tree().get_nodes_in_group("HOUSE")
			for home in placedHomes:
				if abs(get_global_mouse_position().y - home.global_position.y) < 10 :
					if get_global_mouse_position().distance_to(home.global_position) > 30:
						continue
				if abs(get_global_mouse_position().x - home.global_position.x) < 10 :
					if get_global_mouse_position().distance_to(home.global_position) > 30:
						continue
				if get_global_mouse_position().distance_to(home.global_position) < 52:
					return
			for x in range(tile.x,tile.x+2):
				for y in range(tile.y-1,tile.y + 1):
					if !holy_land.has(Vector2i(x,y)) or used_tiles.has(Vector2i(x,y)):
						return
			grass.set_cell(tile,2,Vector2i(0,3),4)
		5:
			for x in range(tile.x -2,tile.x+3):
				for y in range(tile.y-2,tile.y+3):
					grass.set_cell(Vector2(x,y),2,Vector2(0,3),1)
			
			holy.set_cell(tile,1,Vector2(0,0))
	
func gain_resources(tile) -> void:
	var farm_used = farm.get_used_cells()
	var build_used = grass.get_used_cells_by_id(2,Vector2i(0,3),4)
	build_used.append_array(grass.get_used_cells_by_id(2,Vector2i(0,3),5))
	match world.power:
		2:
			var farm_in_range : int
			var non_farm : int
			for x in range(tile.x,tile.x+2):
				for y in range(tile.y-1,tile.y + 1):
					if build_used.has(Vector2i(x,y)):
						continue
					if farm_used.has(Vector2i(x,y)):
						farm_in_range += 1
			for i in range(farm_in_range):
				Global.seeds += 3
	
	world.power = 0

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
	var shrine_tile = holy.get_used_cells_by_id(3,Vector2i(0,0))[0]
	if get_global_mouse_position().distance_to(holy.map_to_local(shrine_tile)) < 64:
		return true
	return false

func place_house(tile : Vector2i):
	var house = HOUSE.instantiate()
	house.global_position = tile
	get_parent().add_child(house)
	#house.global_position = local_to_map(house.global_position)
	house.global_position = map_to_local(house.global_position)
	for x in range(tile.x,tile.x+2):
		for y in range(tile.y-1,tile.y+1):
			grass.set_cell(Vector2i(x,y),2,Vector2i(0,3),5)
func _on_seed_planted(cell) -> void:
	var phase_time : float
	if grass.get_cell_tile_data(cell).get_custom_data("wet") > 1:
		phase_time = (total_grow_time * (.85 - (.05 * (grass.get_cell_tile_data(cell).get_custom_data("wet") - 1) ) ) )
	else:
		phase_time = total_grow_time / (1.0 * 3)
	print(phase_time)
	# grow
	#var growingTile = farm.get_cell_tile_data(tileCoords)
	await get_tree().create_timer(phase_time).timeout
	farm.set_cell(cell,1,Vector2i(2,4))
	await get_tree().create_timer(phase_time).timeout
	farm.set_cell(cell,1,Vector2i(3,4))
	await get_tree().create_timer(phase_time).timeout
	farm.set_cell(cell,1,Vector2i(4,4))
	
