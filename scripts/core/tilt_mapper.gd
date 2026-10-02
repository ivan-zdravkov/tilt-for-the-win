class_name TiltMapper
extends RefCounted
## Turns the phone's gravity sensor reading into the physics gravity for the board.
##
## Device coordinates (Godot's `Input.get_gravity()`): +X towards the right edge of the screen, +Y towards the
## top edge, +Z out of the screen. A phone lying flat, face up, reads about (0, 0, -9.8).
## World coordinates: the board lies in the XZ plane, and the camera looks down -Y with the top of the screen at -Z.
## So lowering the right edge rolls the ball to +X, and lowering the top edge rolls it to -Z.

const STANDARD_GRAVITY := 9.8
const FLAT := Vector3(0, 0, -1)

## Multiplies the in-plane tilt. 1.0 = physically accurate.
var sensitivity := 1.0
## Time constant of the low-pass filter in seconds (higher = smoother but laggier). 0 disables smoothing.
var smoothing_time := 0.06
## Upper bound for the in-plane share of gravity (0..1), so high sensitivity can't produce absurd acceleration.
var max_tilt := 0.9

var _calibration := Quaternion.IDENTITY
var _smoothed := FLAT


## Treats the phone's current orientation as "flat" from now on.
func calibrate(device_gravity: Vector3) -> void:
	if device_gravity.is_zero_approx():
		return
	_calibration = Quaternion(device_gravity.normalized(), FLAT)
	_smoothed = FLAT


func reset_calibration() -> void:
	_calibration = Quaternion.IDENTITY


func is_calibrated() -> bool:
	return not _calibration.is_equal_approx(Quaternion.IDENTITY)


## Feeds one sensor sample (device coordinates) and returns the world gravity vector in m/s².
func update(device_gravity: Vector3, delta: float) -> Vector3:
	if not device_gravity.is_zero_approx():
		var target := _calibration * device_gravity.normalized()
		if smoothing_time > 0.0:
			var weight := 1.0 - exp(-delta / smoothing_time)
			_smoothed = _smoothed.lerp(target, weight).normalized()
		else:
			_smoothed = target
	return device_to_world(_smoothed, sensitivity, max_tilt) * STANDARD_GRAVITY


## Maps a unit gravity direction from device to world coordinates, scaling the in-plane tilt by `sensitivity`
## and capping it at `max_tilt`. The result is a unit vector that always points down into the board.
static func device_to_world(direction: Vector3, tilt_sensitivity := 1.0, tilt_cap := 1.0) -> Vector3:
	var planar := Vector2(direction.x, -direction.y) * tilt_sensitivity  # world X, world Z
	if planar.length() > tilt_cap:
		planar = planar.normalized() * tilt_cap
	var down := -sqrt(maxf(1.0 - planar.length_squared(), 0.0))
	return Vector3(planar.x, down, planar.y)


## Tilts a world-space direction further away from straight down: the in-plane part is multiplied by `factor`
## and capped at `cap`. Used to aim the overhead light along gravity, so small tilts still move the shadows visibly.
static func exaggerate_tilt(direction: Vector3, factor: float, cap := 0.9) -> Vector3:
	if direction.is_zero_approx():
		return Vector3.DOWN
	var unit := direction.normalized()
	var planar := Vector2(unit.x, unit.z) * factor
	if planar.length() > cap:
		planar = planar.normalized() * cap
	return Vector3(planar.x, -sqrt(maxf(1.0 - planar.length_squared(), 0.0)), planar.y)


## Simulates a device gravity reading from keyboard/gamepad input, for playing on desktop.
## `input` is `Input.get_vector(left, right, up, down)`: +X right, +Y down the screen.
static func keyboard_to_device(input: Vector2, max_angle_degrees := 20.0) -> Vector3:
	var angle := deg_to_rad(max_angle_degrees) * minf(input.length(), 1.0)
	if is_zero_approx(angle):
		return FLAT * STANDARD_GRAVITY
	var direction := input.normalized()
	return Vector3(direction.x * sin(angle), -direction.y * sin(angle), -cos(angle)) * STANDARD_GRAVITY
