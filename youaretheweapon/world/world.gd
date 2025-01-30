extends Node2D

const ENEMY = preload("res://Banner/Raider/raider.tscn")
const ENEMY_BANNER = preload("res://Banner/enemy_banner.tscn")

const NON_WINTER_DAYS : int = 4
const WINTER_DAYS : int = 3
const PEACE_DAYS : int = 9

@export var power = Power.NONE
enum Power{
	NONE, # 0
	RAIN,
	WIND,
	QUAKE, 
	BUILDING,
	SHRINE # 5
}
@onready var units : Array = get_child(3).get_children()
@onready var main_ui: CanvasLayer = %MainUI
@onready var tileMap : TileMapLayer = %TileMap
@onready var grassMap: TileMapLayer = tileMap.get_child(1)
@onready var rain : Button = main_ui.rain
@onready var sky: CanvasModulate = %CanvasModulate
@onready var enemies: Node2D = $Enemies

var farmer_demand : int
var farmer_employed : Array

var laborer_demand : int = 1
var laborer_employed : Array

var smith_demand : int
var smith_employed : Array

var children : Array
var adults : Array
var days_until_winter : int
var winter_days : int
var days_until_raid : int

func _ready() -> void:
	$HourTimer.wait_time = 2.5 # Global.total_day_time / 24
	
	days_until_winter = NON_WINTER_DAYS
	days_until_raid = 1 # PEACE_DAYS

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("test"):
		var wow = preload("res://Banner/banner.tscn").instantiate()
		wow.global_position = get_global_mouse_position()
		add_child(wow)
	farmer_demand = (tileMap.farm_tiles - 8) / 9 + 1 if tileMap.farm_tiles > 0 else 0
	smith_demand = get_tree().get_nodes_in_group("FORGE").size()
	
	units = get_child(3).get_children()
	
	assign_jobs()
	assign_homes()
	assign_age()
	assign_workplace()
	handle_builders()
	handle_alerts()
func handle_alerts():
	if Global.food < 10:
		if main_ui.event_log.text.find("Food reserves are low!") == -1:
			main_ui.event_log.text += "\n[color=red]Food reserves are low![/color]"
	if Global.wood < 10:
		if main_ui.event_log.text.find("Wood reserves are low!") == -1:
			main_ui.event_log.text += "\n[color=red]Wood reserves are low![/color]"
	if Global.tools < 10:
		if main_ui.event_log.text.find("Tool reserves are low!") == -1:
			main_ui.event_log.text += "\n[color=red]Tool reserves are low![/color]"
	if days_until_raid == 5:
		if main_ui.event_log.text.find("Raiders arrive in 10 days!") == -1:
			main_ui.event_log.text += "\n[color=yellow]Raiders arrive in 5 days![/color]"
	if days_until_raid == 0:
		if main_ui.event_log.text.find("Raiders approaching from the south!") == -1:
			main_ui.event_log.text += "\n[color=red]Raiders approaching from the south![/color]"
	pass
func handle_builders():
	var house_build = grassMap.get_used_cells_by_id(2,Vector2i(0,3),4)
	var forge_build = grassMap.get_used_cells_by_id(2,Vector2i(0,3),6)
	var need_build : Array
	need_build.append_array(house_build)
	need_build.append_array(forge_build)
	
	if need_build.size() <= 0:
		return
	for unit in laborer_employed:
		if Global.builder_slots.size() < need_build.size():
			if unit.is_in_slot:
				continue
			Global.builder_slots.append(unit)
			unit.is_in_slot = true
		
		for cell in need_build:
			if house_build.has(cell):
				unit.has_resources = true if Global.wood >= 10 and Global.stone >= 2 else false
				continue
			if forge_build.has(cell):
				unit.has_resources = true if Global.wood >= 8 and Global.stone >= 12 else false
				continue
func assign_jobs() -> void:
	for unit in Global.builder_slots:
		if !is_instance_valid(unit):
			continue
		if !unit.is_laborer:
			Global.builder_slots.remove_at(Global.builder_slots.find(unit))
	for unit in units:
		if unit.is_child:
			unit.job = 0 # NONE
			continue
		if unit.is_pregnant:
			unit.job = 0
			continue
		if unit.need_build:
			continue
		if unit.Job.keys()[unit.job] == "LABORER" and !laborer_employed.has(unit):
			laborer_employed.append(unit)
		if unit.Job.keys()[unit.job] == "FARMER" and !farmer_employed.has(unit):
			farmer_employed.append(unit)
		if unit.Job.keys()[unit.job] == "BLACKSMITH" and !smith_employed.has(unit):
			smith_employed.append(unit)
		if unit.Job.keys()[unit.job] == "MINER" and !laborer_employed.has(unit):
			laborer_employed.append(unit)
			
		for i in range(laborer_employed.size()):
			if laborer_employed[i] == null:
				continue
			if i % 2 == 0:
				laborer_employed[i].job = 1
			else:
				laborer_employed[i].job = 4
		if farmer_employed.size() < farmer_demand and laborer_employed.size() > 2:
			farmer_employed.append(laborer_employed[0])
			laborer_employed[0].job = 2 # Farmer index for job enum
			laborer_employed[0].is_in_slot = false
			if Global.builder_slots.has(laborer_employed[0]):
				Global.builder_slots.remove_at(Global.builder_slots.find(laborer_employed[0]))
			laborer_employed.remove_at(0)
		
		if smith_employed.size() < smith_demand and laborer_employed.size() > 2:
			smith_employed.append(laborer_employed[0])
			laborer_employed[0].job = 3
			laborer_employed[0].is_in_slot = false
			laborer_employed.remove_at(0)
func assign_workplace() -> void:
	var forges = get_tree().get_nodes_in_group("FORGE")
	for unit in smith_employed:
		for forge in forges:
			if unit.forge != null:
				continue
			if forge.worker == null:
				unit.forge = forge
				forge.worker = unit
func assign_homes() -> void:
	for unit in units:
		if unit.home != null:
			continue
		# check if homeless
		# if is, then find vacancy
		for house : StaticBody2D in get_tree().get_nodes_in_group("HOUSE"):
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
	tileMap.day_is_passed.emit()
	
	Global.day += 1
	Global.hour = 0
	
	days_until_raid -= 1
	if days_until_raid <= 0:
		for i in range(Global.day / 2):
			var enemy = ENEMY.instantiate()
			enemy.global_position = enemies.global_position
			add_child(enemy)
		
		var enemy_banner = ENEMY_BANNER.instantiate()
		enemy_banner.global_position = enemies.global_position
		add_child(enemy_banner)
		
		tileMap.initiate_raid()
		
		days_until_raid = PEACE_DAYS
		
	if days_until_winter <= 0 and !Global.winter:
		winter_days = WINTER_DAYS
		Global.winter = true
	
	if winter_days <= 0 and Global.winter:
		days_until_winter = NON_WINTER_DAYS
		Global.winter = false
	
	if !Global.winter:
		days_until_winter -= 1
	elif Global.winter:
		winter_days -= 1

func _on_hour_timer_timeout() -> void:
	Global.hour += 1
	if Global.hour >= 24:
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
		
