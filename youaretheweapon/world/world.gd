extends Node2D


@export var build_radius = 3;

@onready var main_ui: CanvasLayer = %MainUI
@onready var tileMap : TileMapLayer = %TileMap
@onready var grassMap: TileMapLayer = tileMap.get_child(2)
@onready var rain : Button = main_ui.rain



var using_rain : bool = false
var building : bool = false


func _process(delta: float) -> void:
	if using_rain:
		pass
	if building:
		pass
		

func _on_timer_timeout() -> void:
	Global.wood = Global.wood - 2
