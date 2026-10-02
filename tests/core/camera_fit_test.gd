extends GdUnitTestSuite

const BOARD := Vector2(9, 16)


func test_tall_phone_is_limited_by_width() -> void:
	var aspect := 1080.0 / 2340.0  # 19.5:9 phone
	var height := CameraFit.ortho_height(BOARD, aspect)
	assert_float(height * aspect).is_equal_approx(9.0, 0.001)
	assert_float(height).is_greater_equal(16.0)


func test_tablet_is_limited_by_height() -> void:
	var aspect := 3.0 / 4.0
	var height := CameraFit.ortho_height(BOARD, aspect)
	assert_float(height).is_equal_approx(16.0, 0.001)
	assert_float(height * aspect).is_greater_equal(9.0)


func test_margin_is_added_on_both_sides() -> void:
	assert_float(CameraFit.ortho_height(BOARD, 0.75, 0.5)).is_equal_approx(17.0, 0.001)


func test_degenerate_aspect_does_not_divide_by_zero() -> void:
	assert_float(CameraFit.ortho_height(BOARD, 0.0)).is_greater(0.0)
