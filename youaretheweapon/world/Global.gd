extends Node

@export var wood := 30
@export var food := 50
@export var seeds := 15
@export var faith := 20
@export var stone := 25
@export var ore := 40
@export var metal := 0
@export var tools := 5
@export var total_day_time := 12
@export var day := 1
@export var hour := 0
@export var action_period = action.WORK
@export var adults := 0
@export var children := 0
@export var builder_slots : Array
@export var winter : bool = true

var quake_rotate : bool = false

enum action {
	WORK,
	REST,
	SLEEP
}

func _process(delta: float) -> void:
	if Global.tools <= 0:
		Global.tools = 0
	if Global.metal <= 0:
		Global.metal = 0
	if Global.ore <= 0:
		Global.ore = 0
	if Global.seeds <= 0:
		Global.seed = 0
	if Global.faith <= 0:
		Global.faith = 0
		
		
