extends GdUnitTestSuite
## Smoke test: the main scene loads, shows the title and the project version.


func test_main_scene_loads_and_shows_version() -> void:
	var runner := scene_runner("res://scenes/main.tscn")
	await runner.simulate_frames(1)

	var title: Label = runner.find_child("Title")
	var version: Label = runner.find_child("Version")
	assert_object(title).is_not_null()
	assert_str(title.text).is_equal("Tilt for the Win")
	assert_str(version.text).is_equal("v%s" % ProjectSettings.get_setting("application/config/version"))
