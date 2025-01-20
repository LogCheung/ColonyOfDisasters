extends CanvasLayer

@onready var world : Node2D = get_parent()
@onready var wood: Label = %WoodLabel
@onready var food: Label = %FoodLabel
@onready var rain: Button = %RainIcon

func _process(_delta: float) -> void: 
	wood.text = "Wood: " + str(Global.wood)
	food.text = "Food: " + str(Global.food)


func _on_rain_icon_pressed() -> void:
	world.using_rain = true

func _on_build_icon_pressed() -> void:
	world.building = true
