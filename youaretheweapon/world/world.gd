extends Node2D


@export var build_radius = 3;

@onready var units : Array = get_child(3).get_children()
@onready var main_ui: CanvasLayer = %MainUI
@onready var tileMap : TileMapLayer = %TileMap
@onready var grassMap: TileMapLayer = tileMap.get_child(2)
@onready var rain : Button = main_ui.rain

var farmer_demand : int
var farmer_employed : Array

var laborer_demand : int = 1
var laborer_employed : Array

var using_rain : bool = false
var building : bool = false


func _process(_delta: float) -> void:
	farmer_demand = tileMap.farm_tiles % 9 + 1 if tileMap.farm_tiles >= 0 else 0
	
	units = get_child(3).get_children()
	assign_jobs()

func _on_timer_timeout() -> void:
	Global.wood = Global.wood - 2

func assign_jobs() -> void:
	for unit in units:
		if unit.Job.keys()[unit.job] == "LABORER" and !laborer_employed.has(unit):
			laborer_employed.append(unit)
		if unit.Job.keys()[unit.job] == "FARMER" and !farmer_employed.has(unit):
			farmer_employed.append(unit)
		
		if farmer_employed.size() < farmer_demand and laborer_employed.size() > 1:
			farmer_employed.append(laborer_employed[0])
			laborer_employed[0].job = 1 # Farmer index for job enum
			laborer_employed.remove_at(0)
