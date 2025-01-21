extends TileMapLayer

@onready var world : Node2D = get_parent()
@onready var grass: TileMapLayer = %Grass
@onready var hover: TileMapLayer = %Hover
@onready var holy: TileMapLayer = %Holy
@onready var farm: TileMapLayer = %Farm

signal seed_planted(cell: Vector2i)

var farm_tiles : int

var grid_size = 160
var dic = {}

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
	if world.building:
		hover.set_cell(Vector2(tile.x - 2,tile.y + 2),0,Vector2(1,1))
		hover.set_cell(Vector2(tile.x + 2,tile.y + 2),0,Vector2(2,1))
		hover.set_cell(Vector2(tile.x + 2,tile.y - 2),0,Vector2(2,0))
		hover.set_cell(Vector2(tile.x - 2,tile.y - 2),0,Vector2(1,0))
		if Input.is_action_just_pressed("SummonWeather"):
			holy.set_cell(tile,1,Vector2(0,0))
			for x in range(tile.x -2,tile.x+3):
				for y in range(tile.y-2,tile.y+3):
					grass.set_cell(Vector2(x,y),2,Vector2(0,3),1)
			world.building = false
	elif world.using_rain:
		var holy_land = grass.get_used_cells_by_id(2,Vector2(0,3),1)
		hover.set_cell(Vector2(tile.x - 1,tile.y + 1),0,Vector2(1,1)) # bot left - +
		hover.set_cell(Vector2(tile.x + 1,tile.y + 1),0,Vector2(2,1)) # bot right + + 
		hover.set_cell(Vector2(tile.x + 1,tile.y - 1),0,Vector2(2,0)) # top left + -
		hover.set_cell(Vector2(tile.x - 1,tile.y - 1),0,Vector2(1,0)) # right - -
		if Input.is_action_just_pressed("SummonWeather"):
			for x in range(tile.x -1,tile.x+2):
				for y in range(tile.y-1,tile.y+2):
					if holy_land.has(Vector2i(x,y)) and !farm.get_used_cells().has(Vector2i(x,y)):
						farm.set_cell(Vector2(x,y),1,Vector2(0,4))
					#else:
						#grass.set_cell(Vector2(x,y),2,Vector2(0,3))
			world.using_rain = false
	else:
		hover.set_cell(tile,0,Vector2(0,0))
	pass


func _on_seed_planted(cell) -> void:
	# grow
	#var growingTile = farm.get_cell_tile_data(tileCoords)
	await get_tree().create_timer(2).timeout
	farm.set_cell(cell,1,Vector2i(2,4))
	await get_tree().create_timer(2).timeout
	farm.set_cell(cell,1,Vector2i(3,4))
	await get_tree().create_timer(2).timeout
	farm.set_cell(cell,1,Vector2i(4,4))
