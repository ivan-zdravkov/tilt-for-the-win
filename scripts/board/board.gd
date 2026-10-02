class_name Board
extends Node3D
## Ball in a box: a walled board whose gravity follows the phone's tilt.
## Tilt is applied by rotating the world's gravity, not by pushing the ball, so the physics stays natural.

## Interior size of the board: x = width, y = depth (the screen's vertical axis).
const BOARD_SIZE := Vector2(9.0, 16.0)
const BALL_START := Vector3(0, 0.4, 0)

@export var camera_margin := 0.4
## How much more the overhead light leans than the phone does. The light hangs "straight above" in the real
## world, so it shines along gravity; exaggerating that makes the shadows visibly swing as you tilt.
@export var light_tilt_factor := 2.5

var tilt := TiltMapper.new()
## When set (a device-space gravity Vector3), replaces sensor/keyboard input. Used by tests.
var input_override: Variant = null
var last_device_gravity := Vector3.ZERO
## Where `last_device_gravity` came from: "override", "gravity sensor", "accelerometer" or "keyboard".
var input_source := ""
var world_gravity := Vector3.DOWN * TiltMapper.STANDARD_GRAVITY

var _default_gravity_vector: Vector3
var _default_gravity: float

@onready var _camera: Camera3D = %Camera
@onready var _ball: RigidBody3D = %Ball
@onready var _sun: DirectionalLight3D = %Sun
@onready var _debug_label: Label = %DebugLabel


func _ready() -> void:
	var space := get_world_3d().space
	_default_gravity_vector = PhysicsServer3D.area_get_param(space, PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR)
	_default_gravity = PhysicsServer3D.area_get_param(space, PhysicsServer3D.AREA_PARAM_GRAVITY)

	get_viewport().size_changed.connect(_fit_camera)
	_fit_camera()

	%BackButton.pressed.connect(_go_back)
	%CalibrateButton.pressed.connect(calibrate)
	%DebugButton.pressed.connect(toggle_debug)
	_debug_label.visible = false


func _exit_tree() -> void:
	# The space is shared with whatever scene comes next, so restore normal gravity.
	var space := get_world_3d().space
	PhysicsServer3D.area_set_param(space, PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR, _default_gravity_vector)
	PhysicsServer3D.area_set_param(space, PhysicsServer3D.AREA_PARAM_GRAVITY, _default_gravity)


func _physics_process(delta: float) -> void:
	last_device_gravity = _read_device_gravity()
	world_gravity = tilt.update(last_device_gravity, delta)
	var space := get_world_3d().space
	PhysicsServer3D.area_set_param(space, PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR, world_gravity.normalized())
	PhysicsServer3D.area_set_param(space, PhysicsServer3D.AREA_PARAM_GRAVITY, world_gravity.length())
	_aim_light()


func _process(_delta: float) -> void:
	if _debug_label.visible:
		_debug_label.text = "input   %s\nsensor  %s\ngravity %s\nball    %s\nfps     %d%s" % [
			input_source, _fmt(last_device_gravity), _fmt(world_gravity), _fmt(_ball.global_position),
			Engine.get_frames_per_second(), "\ncalibrated" if tilt.is_calibrated() else "",
		]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"calibrate"):
		calibrate()
	elif event.is_action_pressed(&"toggle_debug"):
		toggle_debug()
	elif event.is_action_pressed(&"ui_cancel"):
		_go_back()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:  # Android back gesture/button
		_go_back()


## Treats the phone's current angle as flat.
func calibrate() -> void:
	tilt.calibrate(last_device_gravity)


func toggle_debug() -> void:
	_debug_label.visible = not _debug_label.visible


func reset_ball() -> void:
	_ball.linear_velocity = Vector3.ZERO
	_ball.angular_velocity = Vector3.ZERO
	_ball.global_position = BALL_START


## Points the sun along (exaggerated) gravity, as if a lamp hung straight above the real-world table.
func _aim_light() -> void:
	var direction := TiltMapper.exaggerate_tilt(world_gravity, light_tilt_factor)
	_sun.basis = Basis.looking_at(direction, Vector3.FORWARD)


func _read_device_gravity() -> Vector3:
	if input_override != null:
		input_source = "override"
		return input_override
	# Sensors must be enabled in Project Settings > Input Devices > Sensors, or these read zero.
	var sensor := Input.get_gravity()
	if not sensor.is_zero_approx():
		input_source = "gravity sensor"
		return sensor
	# Some phones have no gravity sensor; the raw accelerometer is noisier but the TiltMapper smooths it.
	sensor = Input.get_accelerometer()
	if not sensor.is_zero_approx():
		input_source = "accelerometer"
		return sensor
	input_source = "keyboard"
	return TiltMapper.keyboard_to_device(Input.get_vector(&"tilt_left", &"tilt_right", &"tilt_up", &"tilt_down"))


func _fit_camera() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	_camera.size = CameraFit.ortho_height(BOARD_SIZE, viewport_size.aspect(), camera_margin)


func _go_back() -> void:
	Game.go_to(Game.MAIN_SCENE)


static func _fmt(v: Vector3) -> String:
	return "(%5.2f, %5.2f, %5.2f)" % [v.x, v.y, v.z]
