extends Camera2D

#Camera Controls
@export var SPEED: float = 20.0
@export var ZOOM_SPEED: float = 20.0
@export var ZOOM_MARGIN: float = 0.1
@export var ZOOM_MIN: float = 1.00
@export var ZOOM_MAX: float = 2.5

var zoomFactor: float = 1.0
var zoomPos: Vector2 = Vector2()
var zooming: bool = false

var mousePos: Vector2 = Vector2()
var mousePosGlobal: Vector2 = Vector2()
var start: Vector2 = Vector2()
var startV: Vector2 = Vector2()
var end: Vector2 = Vector2()
var endV: Vector2 = Vector2()
var isDragging: bool = false

@export var box: Panel

#func _ready() -> void:
	#zoom = Vector2(ZOOM_MIN,ZOOM_MIN)

func _process(delta):
	#Zoom
	#zoom.x = lerp(zoom.x, zoom.x * zoomFactor, ZOOM_SPEED * delta)
	#zoom.y = lerp(zoom.y, zoom.y * zoomFactor, ZOOM_SPEED * delta)
	#
	#zoom.x = clamp(zoom.x, ZOOM_MIN, ZOOM_MAX)
	#zoom.y = clamp(zoom.y, ZOOM_MIN, ZOOM_MAX)
	if not zooming:
		zoomFactor = 1.0
	
	
	#Movement
	var inputX = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	var inputY = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	position.x = lerp(position.x, position.x + inputX * SPEED * zoom.x, SPEED * delta)
	position.y = lerp(position.y, position.y + inputY * SPEED * zoom.y, SPEED * delta)
	
func _input(event: InputEvent) -> void:
	#input_for_zoom(event)
	if abs(zoomPos.x - get_global_mouse_position().x) > ZOOM_MARGIN:
		zoomFactor = 1
	if abs(zoomPos.y - get_global_mouse_position().y) > ZOOM_MARGIN:
		zoomFactor = 1
		#
	if event is InputEventMouseButton:
		if event.is_pressed():
			zooming = true
			if event.is_action("WheelDown"):
				zoomFactor -= 0.01 * ZOOM_SPEED
				zoomPos = get_global_mouse_position()
			if event.is_action("WheelUp"):
				zoomFactor += 0.01 * ZOOM_SPEED
				zoomPos = get_global_mouse_position()
		else:
			zooming = false
	if event is InputEventMouse:
		mousePos = event.position
		mousePosGlobal = get_global_mouse_position()
