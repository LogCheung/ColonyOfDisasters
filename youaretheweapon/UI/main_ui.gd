extends CanvasLayer

const ALLY_POWER = preload("res://Banner/UI/ally_power.tscn")

@onready var world : Node2D = get_parent()
@onready var wood: Label = %WoodLabel
@onready var food: Label = %FoodLabel
@onready var rain: Button = %RainIcon
@onready var seeds: Label = %SeedLabel
@onready var faith: Label = %FaithLabel
@onready var choice_alert: Control = %ChoiceAlert
@onready var adults: Label = %AdultsLabel
@onready var child: Label = %ChildLabel
@onready var stone: Label = %StoneLabel
@onready var ore: Label = %OreLabel
@onready var metal: Label = %MetalLabel
@onready var tools: Label = %ToolsLabel

@onready var wind_audio: AudioStreamPlayer2D = %WindAudio
@onready var rain_audio: AudioStreamPlayer2D = %RainAudio

#@onready var ally_power: Control = %AllyPower


var proceed : int = 3 # none
var enemy_raid
var ally_raid 

func _process(_delta: float) -> void: 
	wood.text = " " + str(Global.wood)
	food.text = " " + str(Global.food)
	seeds.text = " " + str(Global.seeds)
	faith.text = " " + str(Global.faith)
	adults.text = " " + str(Global.adults)
	child.text = " " + str(Global.children) 
	stone.text = " " + str(Global.stone)
	ore.text = " " + str(Global.ore)
	metal.text = " " + str(Global.metal)
	tools.text = " " + str(Global.tools)
	
	#if world.power == 3:
		#%Keybind.visible = true
		#if Input.is_action_just_pressed("Rotate"):
			#Global.quake_rotate = !Global.quake_rotate
	#else:
		#Global.quake_rotate = false
		#%Keybind.visible = false
	enemy_raid = get_tree().get_first_node_in_group("ENEMYBANNER")
	ally_raid = get_tree().get_first_node_in_group("ALLYBANNER")
	
	#if ally_raid != null:
		#ally_power.global_position = ally_raid.global_position
		#print("lol " + str(ally_power.global_position))

func _on_rain_icon_pressed() -> void:
	world.power = 1

func _on_build_icon_pressed() -> void:
	world.power = 4
	
func _on_quake_icon_pressed() -> void:
	world.power = 3
	
func _on_wind_icon_pressed() -> void:
	world.power = 2


func _on_yes_pressed() -> void:
	proceed = 0 # yes
	choice_alert.visible = false

func _on_no_pressed() -> void:
	proceed = 1 # no
	choice_alert.visible = false

func play_sound(power : int):
	match power:
		1:
			rain_audio.play()
			await get_tree().create_timer(1.5).timeout
			rain_audio.stop()
		2:
			wind_audio.play()
			await get_tree().create_timer(1.5).timeout
			wind_audio.stop()
