extends Node

@export var wood := 10
@export var food := 25
@export var seeds := 15
@export var faith := 30
@export var stone := 10
@export var ore := 0
@export var metal := 0
@export var tools := 10
@export var total_day_time := 120
@export var day := 1
@export var hour := 0
@export var action_period = action.WORK
@export var adults := 0
@export var children := 0
@export var builder_slots : Array
@export var winter : bool = false
@export var satisfaction : float

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
		Global.seeds = 0
	if Global.faith <= 0:
		Global.faith = 0
	
	if get_tree().get_first_node_in_group("ADULT") != null:
		var sum : float = 0.0
		for unit in get_tree().get_nodes_in_group("ADULT"):
			sum += unit.satisfaction
		Global.satisfaction = roundf(sum / (1.0 * get_tree().get_nodes_in_group("ADULT").size()))
