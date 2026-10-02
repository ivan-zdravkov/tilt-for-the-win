extends GdUnitTestSuite


func test_formats_zero() -> void:
	assert_str(TimeFormat.format_ms(0)).is_equal("00:00:00:000")


func test_formats_all_fields() -> void:
	# 1 h 2 min 3 s 45 ms
	assert_str(TimeFormat.format_ms(3_723_045)).is_equal("01:02:03:045")


func test_pads_milliseconds_to_three_digits() -> void:
	assert_str(TimeFormat.format_ms(7)).is_equal("00:00:00:007")


func test_rolls_seconds_and_minutes_over() -> void:
	assert_str(TimeFormat.format_ms(59_999)).is_equal("00:00:59:999")
	assert_str(TimeFormat.format_ms(60_000)).is_equal("00:01:00:000")
	assert_str(TimeFormat.format_ms(3_600_000)).is_equal("01:00:00:000")


func test_hours_grow_past_two_digits() -> void:
	assert_str(TimeFormat.format_ms(100 * 3_600_000)).is_equal("100:00:00:000")


func test_clamps_negative_to_zero() -> void:
	assert_str(TimeFormat.format_ms(-5)).is_equal("00:00:00:000")
