extends Node2D


@export var power = Power.NONE
enum Power{
	NONE,
	RAIN,
	WIND,
	QUAKE,
	VOLCANO,
	BUILDING
}

@onready var units : Array = get_child(3).get_children()
@onready var main_ui: CanvasLayer = %MainUI
@onready var tileMap : TileMapLayer = %TileMap
@onready var grassMap: TileMapLayer = tileMap.get_child(1)
@onready var rain : Button = main_ui.rain
@onready var sky: CanvasModulate = %CanvasModulate

var farmer_demand : int
var farmer_employed : Array

var laborer_demand : int = 1
var laborer_employed : Array

var children : Array
var adults : Array

func _ready() -> void:
	$HourTimer.wait_time = 2.5 # Global.total_day_time / 24

func _process(_delta: float) -> void:
	farmer_demand = tileMap.farm_tiles / 9 + 1 if tileMap.farm_tiles >= 0 else 0
	
	units = get_child(3).get_children()
	
	
	assign_jobs()
	assign_homes()
	assign_age()
	handle_builders()
func handle_builders():
	var need_build = grassMap.get_used_cells_by_id(2,Vector2i(0,3),4)
	if need_build.size() <= 0:
		return
	for unit in laborer_employed:
		if unit.is_in_slot:
			continue
		if Global.builder_slots.size() < need_build.size():
			Global.builder_slots.append(unit)
			unit.is_in_slot = true

func assign_jobs() -> void:
	for unit in units:
		if unit.is_child:
			unit.job = 0 # NONE
			continue
		if unit.is_pregnant:
			unit.job = 0
			continue
		if unit.Job.keys()[unit.job] == "LABORER" and !laborer_employed.has(unit):
			laborer_employed.append(unit)
		if unit.Job.keys()[unit.job] == "FARMER" and !farmer_employed.has(unit):
			farmer_employed.append(unit)
		
		if farmer_employed.size() < farmer_demand and laborer_employed.size() > 1:
			farmer_employed.append(laborer_employed[0])
			laborer_employed[0].job = 2 # Farmer index for job enum
			laborer_employed.remove_at(0)

func assign_homes() -> void:
	for unit in units:
		if unit.home != null:
			continue
		# check if homeless
		# if is, then find vacancy
		for house : House in get_tree().get_nodes_in_group("HOUSE"):
			if house.slot1 == null:
				house.slot1 = unit
				unit.home = house
			elif house.slot2 == null:
				house.slot2 = unit
				unit.home = house
func assign_age() -> void:
	adults = []
	children = []
	for unit in units:
		if unit.is_child:
			children.append(unit)
		else:
			adults.append(unit)
	Global.children = children.size()
	Global.adults = adults.size()

func signal_day_passed():
	for unit in units:
		unit.day_passed.emit()

func _on_hour_timer_timeout() -> void:
	Global.hour += 1
	if Global.hour >= 24:
		Global.day += 1
		Global.hour = 0
		signal_day_passed()
		
	if Global.hour < 16:
		Global.action_period = 0 # Work
		sky.color.r8 = 255
		sky.color.g8 = 255
		sky.color.b8 = 255
	elif Global.hour >= 16 and Global.hour < 21:
		Global.action_period = 1 # Rest
		sky.color.r8 = 201
		sky.color.g8 = 185
		sky.color.b8 = 127
	else:
		Global.action_period = 2 # Sleep
		sky.color.r8 = 135
		sky.color.g8 = 128
		sky.color.b8 = 95
		
