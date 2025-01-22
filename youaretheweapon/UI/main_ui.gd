extends CanvasLayer

@onready var world : Node2D = get_parent()
@onready var wood: Label = %WoodLabel
@onready var food: Label = %FoodLabel
@onready var rain: Button = %RainIcon
@onready var seeds: Label = %SeedLabel
@onready var faith: Label = %FaithLabel
@onready var choice_alert: Control = %ChoiceAlert
@onready var adults: Label = %AdultsLabel
@onready var child: Label = %ChildLabel

var proceed : int = 3 # none

func _process(_delta: float) -> void: 
	wood.text = "  " + str(Global.wood)
	food.text = " " + str(Global.food)
	seeds.text = " " + str(Global.seeds)
	faith.text = " " + str(Global.faith)
	adults.text = " " + str(Global.adults)
	child.text = " " + str(Global.children) 
	
	

func _on_rain_icon_pressed() -> void:
	world.power = 1

func _on_build_icon_pressed() -> void:
	world.power = 5

func _on_wind_icon_pressed() -> void:
	world.power = 2


func _on_yes_pressed() -> void:
	proceed = 0 # yes
	choice_alert.visible = false

func _on_no_pressed() -> void:
	proceed = 1 # no
	choice_alert.visible = false
