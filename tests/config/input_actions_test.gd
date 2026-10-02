extends GdUnitTestSuite


func test_all_game_actions_are_registered() -> void:
	for action: StringName in Game.INPUT_ACTIONS:
		assert_bool(InputMap.has_action(action)).override_failure_message("missing action %s" % action).is_true()
