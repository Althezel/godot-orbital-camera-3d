class_name OrbitalCamera3D

extends Camera3D

var cameraAnchorNode: Node3D

var canZoom: bool = true
const ZOOM_MIN: float = 5
const ZOOM_MAX: float = 25
const ZOOM_STEP: float = 5
const ZOOM_SPEED: float = 1
@export_range(ZOOM_MIN, ZOOM_MAX, ZOOM_STEP) var zoom: float = 10

var isRotateMode: bool = false
var canRotate: bool = true
var mouseRel: Vector2 = Vector2.ZERO
const ROTATE_HORIZONTAL_STEP: float = 30
const ROTATE_VERTICAL_STEP: float = 20
const ROTATE_VERTICAL_MIN: float = 20
const ROTATE_VERTICAL_MAX: float = 80
const ROTATE_SPEED: float = 0.5
@export_range(0, 300, 1) var mouseSensitivity: float = 150
@export_range(ROTATE_VERTICAL_MIN, ROTATE_VERTICAL_MAX, ROTATE_VERTICAL_STEP) var rotVertical: float = 20
@export_range(0, 360, ROTATE_HORIZONTAL_STEP) var rotHorizontal: float = 0

func _ready():
	cameraAnchorNode = $".."
	position.x = zoom
	cameraAnchorNode.rotation_degrees.y = rotHorizontal
	cameraAnchorNode.rotation_degrees.z = rotVertical

func _process(_delta):
	_camera_process_rotation()

func _input(event):
	if event.is_action_pressed("camera_drag"):
		isRotateMode = true
	if event.is_action_released("camera_drag"):
		isRotateMode = false
	if canZoom:
		if event.is_action_pressed("camera_zoom_out", true):
			_camera_process_zoom(ZOOM_STEP)
			return
		if event.is_action_pressed("camera_zoom_in", true):
			_camera_process_zoom(ZOOM_STEP * -1)
			return
	if canRotate && isRotateMode:
		if event is InputEventKey:
			if event.is_action_pressed("camera_rotate_left", true, true):
				mouseRel = Vector2(1, 0)
			elif event.is_action_pressed("camera_rotate_right", true, true):
				mouseRel = Vector2(-1, 0)
			elif event.is_action_pressed("camera_rotate_down", true, true):
				mouseRel = Vector2(0, -1)
			elif event.is_action_pressed("camera_rotate_up", true, true):
				mouseRel = Vector2(0, 1)
			return
		elif event is InputEventMouseMotion && (abs(event.velocity.y) > mouseSensitivity || abs(event.velocity.x) > mouseSensitivity):
			mouseRel = event.relative

func _camera_process_zoom(zoomIncrement: float):
	canZoom = false
	zoom = clampf(zoom + zoomIncrement, ZOOM_MIN, ZOOM_MAX)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector3(zoom, 0, 0), ZOOM_SPEED).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_camera_zoom_finished)

func _camera_zoom_finished():
	canZoom = true

func _camera_process_rotation():
	if canRotate && mouseRel != Vector2.ZERO:
		if abs(mouseRel.y) > abs(mouseRel.x):
			if mouseRel.y > 0:
				_camera_process_rotation_vertical(ROTATE_VERTICAL_STEP)
			else:
				_camera_process_rotation_vertical(ROTATE_VERTICAL_STEP * -1)
		else:
			if mouseRel.x > 0:
				_camera_process_rotation_horizontal(ROTATE_HORIZONTAL_STEP * -1)
			else:
				_camera_process_rotation_horizontal(ROTATE_HORIZONTAL_STEP)

func _camera_process_rotation_vertical(rotationIncrement: float):
	canRotate = false
	rotVertical = clampf(rotVertical + rotationIncrement, ROTATE_VERTICAL_MIN, ROTATE_VERTICAL_MAX)
	var tween = get_tree().create_tween()
	tween.tween_property(cameraAnchorNode, "rotation_degrees", Vector3(0, rotHorizontal, rotVertical), ROTATE_SPEED).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_camera_rotation_finished)

func _camera_process_rotation_horizontal(rotationIncrement: float):
	canRotate = false
	rotHorizontal += rotationIncrement
	var tween = get_tree().create_tween()
	tween.tween_property(cameraAnchorNode, "rotation_degrees", Vector3(0, rotHorizontal, rotVertical), ROTATE_SPEED).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_camera_rotation_finished)
	
func _camera_rotation_finished():
	mouseRel = Vector2.ZERO
	canRotate = true
	if rotHorizontal >= 360:
		rotHorizontal -= 360
	elif rotHorizontal < 0:
		rotHorizontal += 360
	cameraAnchorNode.rotation_degrees.y = rotHorizontal
