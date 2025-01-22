extends Node

@export var wood := 10
@export var food := 15
@export var seeds := 15
@export var faith := 20
@export var total_day_time := 12
@export var day := 1
@export var hour := 0
@export var action_period = action.WORK
@export var adults := 0
@export var children := 0
@export var builder_slots : Array

enum action {
	WORK,
	REST,
	SLEEP
}
