extends GdUnitTestSuite
## Physics tests for the ball-in-a-box board, driven through Board.input_override (no sensor needed).

const HALF_WIDTH := Board.BOARD_SIZE.x / 2.0
const HALF_DEPTH := Board.BOARD_SIZE.y / 2.0


func _board_runner() -> GdUnitSceneRunner:
	var runner := scene_runner("res://scenes/board/board.tscn")
	(runner.scene() as Board).tilt.smoothing_time = 0.0
	return runner


func _ball(runner: GdUnitSceneRunner) -> RigidBody3D:
	return runner.find_child("Ball")


func test_ball_stays_put_on_a_flat_board() -> void:
	var runner := _board_runner()
	(runner.scene() as Board).input_override = Vector3(0, 0, -TiltMapper.STANDARD_GRAVITY)
	await runner.simulate_frames(60, 16)
	var ball_position := _ball(runner).global_position
	assert_float(Vector2(ball_position.x, ball_position.z).length()).is_less(0.05)


func test_ball_rolls_towards_the_lowered_edge() -> void:
	var runner := _board_runner()
	(runner.scene() as Board).input_override = TiltMapper.keyboard_to_device(Vector2.RIGHT, 15.0)
	await runner.simulate_frames(40, 16)
	var ball_position := _ball(runner).global_position
	assert_float(ball_position.x).is_greater(0.3)
	assert_float(absf(ball_position.z)).is_less(0.1)


func test_walls_keep_the_ball_on_the_board() -> void:
	var runner := _board_runner()
	var board := runner.scene() as Board
	board.tilt.sensitivity = 3.0
	board.input_override = TiltMapper.keyboard_to_device(Vector2(-1, -1), 30.0)  # hard towards the top-left corner
	await runner.simulate_frames(300, 16)
	var ball_position := _ball(runner).global_position
	assert_float(ball_position.x).is_between(-HALF_WIDTH, HALF_WIDTH)
	assert_float(ball_position.z).is_between(-HALF_DEPTH, HALF_DEPTH)
	assert_float(ball_position.y).is_greater(0.0)
	assert_float(ball_position.x).is_less(-HALF_WIDTH + 1.0)  # it actually reached the corner


func test_leaving_the_board_restores_normal_gravity() -> void:
	var runner := _board_runner()
	var board := runner.scene() as Board
	board.input_override = TiltMapper.keyboard_to_device(Vector2.RIGHT, 30.0)
	await runner.simulate_frames(5, 16)
	var space := board.get_world_3d().space
	board.get_parent().remove_child(board)
	assert_vector(PhysicsServer3D.area_get_param(space, PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR)).is_equal(Vector3.DOWN)
	board.queue_free()


func test_calibrate_uses_the_latest_reading() -> void:
	var runner := _board_runner()
	var board := runner.scene() as Board
	board.input_override = TiltMapper.keyboard_to_device(Vector2.DOWN, 30.0)  # phone held tilted towards the player
	await runner.simulate_frames(2, 16)
	board.calibrate()
	board.reset_ball()  # discard the speed it picked up before calibrating
	await runner.simulate_frames(60, 16)
	var ball_position := _ball(runner).global_position
	assert_bool(board.tilt.is_calibrated()).is_true()
	assert_float(Vector2(ball_position.x, ball_position.z).length()).is_less(0.1)
