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
@onready var happy: Label = %HappyLabel
@onready var hour: Label = %HourLabel

@onready var wind_audio: AudioStreamPlayer2D = %WindAudio
@onready var rain_audio: AudioStreamPlayer2D = %RainAudio
@onready var event_log: RichTextLabel = %EventLog

@onready var song1: AudioStreamPlayer2D = $Song1
@onready var unable: Control = %UnableWarning

#@onready var ally_power: Control = %AllyPower


var proceed : int = 3 # none
var enemy_raid
var ally_raid 
func _ready() -> void:
	event_log.text += "Welcome to your colony, use the elements to help your colony thrive"
	event_log.text += "\n\nStart by designating holy land"
	event_log.text += "\n\nUse the elements to encourage buildings"
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
	happy.text = "  " + str(Global.satisfaction) + "%"
	hour.text = "Hour : " + str(Global.hour) + ":00" 
	
	
	while event_log.get_line_count() > 10:
		var remove_after : int = event_log.text.findn("\n")
		event_log.text = event_log.text.substr(remove_after + 1)
	enemy_raid = get_tree().get_first_node_in_group("ENEMYBANNER")
	ally_raid = get_tree().get_first_node_in_group("ALLYBANNER")

func _on_rain_icon_pressed() -> void:
	unable.visible =true
	world.power = 1

func _on_build_icon_pressed() -> void:
	unable.visible =true
	world.power = 4
	
func _on_quake_icon_pressed() -> void:
	unable.visible =true
	world.power = 3
	
func _on_wind_icon_pressed() -> void:
	unable.visible =true
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


func _on_rain_icon_mouse_entered() -> void:
	%RainLabel.text = "      Rain
	
[color=yellow]Cost: 5 Faith [/color]

Encourages farm land and can improve growth

Can weaken raider and cause floods

During winter it can cause colds and damage farms
"
	%RainDesc.visible = true
	%RainLabel.visible = true
func _on_rain_icon_mouse_exited() -> void:
	%RainDesc.visible = !true
	%RainLabel.visible = !true

func _on_wind_icon_mouse_entered() -> void:
	%WindLabel.text = "      Wind
	
[color=yellow]Cost: 5 Faith [/color]

Encourages housing, gathers seeds from farms or plants trees

Can weakean raiders

During winter it can cause colds
"
	%WindDesc.visible = true 
	%WindLabel.visible = true 

func _on_wind_icon_mouse_exited() -> void:
	%WindDesc.visible = !true 
	%WindLabel.visible = !true 


func _on_quake_icon_mouse_entered() -> void:
	%QuakeLabel.text = "   Earthquake
	
[color=yellow]Cost: 10 Faith [/color]

Encourages a forge and can uproot trees for wood

Can destroy and weaken raiders

Brings ore, for tools, up to the ground
"
	%QuakeDesc.visible = true 
	%QuakeLabel.visible = true 
func _on_quake_icon_mouse_exited() -> void:
	%QuakeDesc.visible = !true 
	%QuakeLabel.visible = !true 


func _on_build_icon_mouse_entered() -> void:
	%BuildLabel.text = "    Holy Land
	
[color=yellow]Cost: 2 Faith [/color]

Designate holy land, where villagers will build what is encouraged.

"
	%BuildDesc.visible = true 
	%BuildLabel.visible = true 

func _on_build_icon_mouse_exited() -> void:
	%BuildDesc.visible = !true 
	%BuildLabel.visible = !true 
