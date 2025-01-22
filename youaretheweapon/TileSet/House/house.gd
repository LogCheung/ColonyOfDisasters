class_name House extends StaticBody2D

var NPC = preload("res://npcs/npc.tscn")

@export var slot1 : CharacterBody2D
@export var slot2 : CharacterBody2D

@onready var bed: Node2D = $bed
@onready var world : Node2D = get_parent()
@onready var mainUi = get_parent().get_child(1)

var selected = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Cancel"):
		selected = false
	if get_global_mouse_position().distance_to(global_position) < 20 and world.power == 0:
		if Input.is_action_just_pressed("SummonWeather"):
			selected = true
		%Sprite2D.material = preload("res://TileSet/House/houseOutline.tres")
		if selected:
			%Sprite2D.material = preload("res://TileSet/House/houseOutline.tres")
			$Button.visible = true
	else:
		if !selected:
			%Sprite2D.material = null
			$Button.visible = false
		
	if mainUi.proceed == 0:
		# if yes
		if !slot1.is_pregnant:
			slot1.is_pregnant = true
			Global.food -= 1
			
			var npc = NPC.instantiate()
			npc.is_child = true
			npc.global_position = bed.global_position
			get_parent().get_child(3).add_child(npc)
		else:
			# warn them on unable warning label
			pass
		mainUi.proceed = 3
	else:
		mainUi.proceed = 3

func _on_button_pressed() -> void:
	selected = false
	# choice label is child 0, button is child 1
	mainUi.choice_alert.get_child(0).text = "Give birth to child? \nOne person will be unable to work\n 1 Food Required\nProceed?"
	mainUi.choice_alert.visible = true
	$Button.visible = false
