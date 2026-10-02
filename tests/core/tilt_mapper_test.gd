extends GdUnitTestSuite

const G := TiltMapper.STANDARD_GRAVITY


func _tilted(right: float, top: float) -> Vector3:
	## Device gravity for a phone whose right edge is lowered by `right` degrees and top edge by `top` degrees.
	return TiltMapper.keyboard_to_device(Vector2(sin(deg_to_rad(right)), -sin(deg_to_rad(top))).limit_length(1.0), 90.0)


func _mapper_without_smoothing() -> TiltMapper:
	var mapper := TiltMapper.new()
	mapper.smoothing_time = 0.0
	return mapper


func test_flat_phone_gives_straight_down_gravity() -> void:
	var gravity := _mapper_without_smoothing().update(Vector3(0, 0, -G), 1.0 / 60.0)
	assert_vector(gravity).is_equal_approx(Vector3(0, -G, 0), Vector3.ONE * 0.001)


func test_lowering_right_edge_rolls_ball_right() -> void:
	var gravity := _mapper_without_smoothing().update(Vector3(G * 0.3, 0, -G), 1.0 / 60.0)
	assert_float(gravity.x).is_greater(0.0)
	assert_float(gravity.z).is_equal_approx(0.0, 0.001)
	assert_float(gravity.y).is_less(0.0)


func test_lowering_top_edge_rolls_ball_up_the_screen() -> void:
	var gravity := _mapper_without_smoothing().update(Vector3(0, G * 0.3, -G), 1.0 / 60.0)
	assert_float(gravity.z).is_less(0.0)  # -Z is the top of the screen
	assert_float(gravity.x).is_equal_approx(0.0, 0.001)


func test_output_magnitude_is_standard_gravity() -> void:
	var gravity := _mapper_without_smoothing().update(Vector3(3, -2, -8), 1.0 / 60.0)
	assert_float(gravity.length()).is_equal_approx(G, 0.001)


func test_calibration_makes_current_angle_flat() -> void:
	var mapper := _mapper_without_smoothing()
	var holding_angle := Vector3(0, -G * sin(deg_to_rad(35)), -G * cos(deg_to_rad(35)))  # tilted towards the player
	mapper.calibrate(holding_angle)
	assert_bool(mapper.is_calibrated()).is_true()
	assert_vector(mapper.update(holding_angle, 1.0 / 60.0)).is_equal_approx(Vector3(0, -G, 0), Vector3.ONE * 0.001)


func test_reset_calibration_restores_raw_mapping() -> void:
	var mapper := _mapper_without_smoothing()
	mapper.calibrate(Vector3(1, -3, -9))
	mapper.reset_calibration()
	assert_bool(mapper.is_calibrated()).is_false()
	assert_vector(mapper.update(Vector3(0, 0, -G), 1.0 / 60.0)).is_equal_approx(Vector3(0, -G, 0), Vector3.ONE * 0.001)


func test_calibrating_with_zero_vector_is_ignored() -> void:
	var mapper := TiltMapper.new()
	mapper.calibrate(Vector3.ZERO)
	assert_bool(mapper.is_calibrated()).is_false()


func test_smoothing_converges_on_the_target() -> void:
	var mapper := TiltMapper.new()
	mapper.smoothing_time = 0.06
	var tilted := Vector3(G * 0.5, 0, -G * 0.866)
	var first := mapper.update(tilted, 1.0 / 60.0)
	for i in 120:
		mapper.update(tilted, 1.0 / 60.0)
	var settled := mapper.update(tilted, 1.0 / 60.0)
	var expected := TiltMapper.device_to_world(tilted.normalized(), 1.0, mapper.max_tilt) * G
	assert_float(first.x).is_less(settled.x)  # the first frame only moves part of the way
	assert_vector(settled).is_equal_approx(expected, Vector3.ONE * 0.01)


func test_zero_sensor_reading_keeps_previous_gravity() -> void:
	var mapper := _mapper_without_smoothing()
	var before := mapper.update(Vector3(G * 0.3, 0, -G), 1.0 / 60.0)
	assert_vector(mapper.update(Vector3.ZERO, 1.0 / 60.0)).is_equal_approx(before, Vector3.ONE * 0.001)


func test_sensitivity_amplifies_tilt_up_to_the_cap() -> void:
	var direction := Vector3(0.2, 0, -0.98).normalized()
	var normal := TiltMapper.device_to_world(direction, 1.0, 0.9)
	var doubled := TiltMapper.device_to_world(direction, 2.0, 0.9)
	assert_float(doubled.x).is_equal_approx(normal.x * 2.0, 0.001)
	var capped := TiltMapper.device_to_world(direction, 100.0, 0.9)
	assert_float(Vector2(capped.x, capped.z).length()).is_equal_approx(0.9, 0.001)
	assert_float(capped.y).is_less(0.0)


func test_keyboard_neutral_is_flat() -> void:
	assert_vector(TiltMapper.keyboard_to_device(Vector2.ZERO)).is_equal_approx(Vector3(0, 0, -G), Vector3.ONE * 0.001)


func test_keyboard_directions_match_device_conventions() -> void:
	assert_float(TiltMapper.keyboard_to_device(Vector2.RIGHT).x).is_greater(0.0)
	assert_float(TiltMapper.keyboard_to_device(Vector2.UP).y).is_greater(0.0)  # top edge lowered
	var tilted := TiltMapper.keyboard_to_device(Vector2.RIGHT, 20.0)
	assert_float(rad_to_deg(acos(-tilted.z / G))).is_equal_approx(20.0, 0.01)


func test_exaggerate_tilt_keeps_straight_down() -> void:
	assert_vector(TiltMapper.exaggerate_tilt(Vector3.DOWN * G, 3.0)).is_equal_approx(Vector3.DOWN, Vector3.ONE * 0.001)
	assert_vector(TiltMapper.exaggerate_tilt(Vector3.ZERO, 3.0)).is_equal(Vector3.DOWN)


func test_exaggerate_tilt_scales_the_lean_up_to_the_cap() -> void:
	var gravity := Vector3(0.1, -0.99, -0.05).normalized()
	var leaned := TiltMapper.exaggerate_tilt(gravity, 2.0)
	assert_float(leaned.x).is_equal_approx(gravity.x * 2.0, 0.001)
	assert_float(leaned.z).is_equal_approx(gravity.z * 2.0, 0.001)
	assert_float(leaned.length()).is_equal_approx(1.0, 0.001)
	var capped := TiltMapper.exaggerate_tilt(gravity, 100.0, 0.7)
	assert_float(Vector2(capped.x, capped.z).length()).is_equal_approx(0.7, 0.001)
	assert_float(capped.y).is_less(0.0)
