extends StaticBody2D

var NPC = preload("res://npcs/npc.tscn")

@export var slot1 : CharacterBody2D
@export var slot2 : CharacterBody2D

@onready var bed: Node2D = $bed
@onready var world : Node2D = get_parent()
@onready var mainUi = get_parent().get_child(1)
@onready var tileMap : TileMapLayer = get_parent().get_child(0)
@onready var grassTiles : TileMapLayer = tileMap.get_child(1)


var selected = false

func _process(delta: float) -> void:
	# check if not damaged
	check_if_damaged()
	if Input.is_action_just_pressed("Cancel"):
		selected = false
	if get_global_mouse_position().distance_to(global_position) < 20 and world.power == 0:
		if Input.is_action_just_pressed("SummonWeather"):
			for house in get_tree().get_nodes_in_group("HOUSE"):
				house.selected = false
			selected = true
		%Sprite2D.material = preload("res://TileSet/House/houseOutline.tres")
		if selected:
			%Sprite2D.material = preload("res://TileSet/House/houseOutline.tres")
			$Button.visible = true
	else:
		if !selected:
			%Sprite2D.material = null
			$Button.visible = false
	
	if !selected:
		pass
	elif mainUi.proceed == 0:
		if !Global.food >= 1:
			mainUi.proceed = 3
			return
		# if yes
		if !self.slot1.is_pregnant:
			var npc = NPC.instantiate()
			npc.is_child = true
			npc.global_position = self.bed.global_position
			get_parent().get_child(3).add_child(npc)
			slot1.is_pregnant = true
			Global.food -= 1
		else:
			# warn them on unable warning label
			pass
		mainUi.proceed = 3
		selected = false
	elif mainUi.proceed == 1:
		selected = false
	else:
		mainUi.proceed = 3
func check_if_damaged():
	var building_tiles = grassTiles.get_used_cells_by_id(2,Vector2i(0,3),5)
	var house_pos = grassTiles.local_to_map(global_position)
	if !building_tiles.has(house_pos):
		if slot1 != null:
			slot1.home = null
		if slot2 != null:
			slot2.home = null
		queue_free()

func _on_button_pressed() -> void:
	# choice label is child 0, button is child 1
	mainUi.choice_alert.get_child(0).text = "Give birth to child? \nOne person will be unable to work\n 1 Food Required\nProceed?"
	mainUi.choice_alert.visible = true
	$Button.visible = false
